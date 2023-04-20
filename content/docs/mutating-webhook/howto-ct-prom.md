---
title: Injecting consul-template into the Prometheus operator for Vault metrics
shortTitle: Injecting secrets into Prometheus
weight: 400
---

To get vault metrics into Prometheus you need to log in to Vault to get access to a native Vault endpoint that provides the metrics.

## Workflow

1. The webhook injects `vault-agent` as an init container, based on the Kubernetes Auth role configuration `prometheus-operator-prometheus`.
1. The vault-agent grabs a token with the policy of `prometheus-operator-prometheus`.
1. `consul-template` runs as a sidecar, and uses the token from the previous step to retrieve a new token using the Token Auth role `prometheus-metrics` which has the policy `prometheus-metrics` applied to it.
1. Prometheus can now use this second token to read the Vault Prometheus endpoint.

The trick here is that Prometheus runs with the SecurityContext UID of 1000 but the default `consul-template` image is running under the UID of 100. This is because of a Dockerfile Volume that is configured which dockerd mounts as 100 (/consul-template/data).

Subsequently using this `consul-template` means it will never start, so we need to ensure we do not use this declared volume and change the UID using a custom Dockerfile and entrypoint.

## Prerequisites

This document assumes you have a working Kubernetes cluster which has a:

- You have a working Kubernetes cluster which has:

    - a working Vault installation
    - a working installation of the [mutating webhook](/docs/bank-vaults/mutating-webhook/).

- You have the [CoreOS Prometheus Operator](https://github.com/coreos/prometheus-operator) installed and working.
- You have a working knowledge of Kubernetes.
- You can apply Deployments or PodSpec's to the cluster.
- You can change the configuration of the mutating webhook.

## Configuration

### Custom consul-template image; docker-entrypoint.sh

```bash
#!/bin/dumb-init /bin/sh
set -ex

# Note above that we run dumb-init as PID 1 in order to reap zombie processes
# as well as forward signals to all processes in its session. Normally, sh
# wouldn't do either of these functions so we'd leak zombies as well as do
# unclean termination of all our sub-processes.

# CONSUL_DATA_DIR is exposed as a volume for possible persistent storage.
# CT_CONFIG_DIR isn't exposed as a volume but you can compose additional config
# files in there if you use this image as a base, or use CT_LOCAL_CONFIG below.
CT_DATA_DIR=/consul-template/config
CT_CONFIG_DIR=/consul-template/config

# You can also set the CT_LOCAL_CONFIG environment variable to pass some
# Consul Template configuration JSON without having to bind any volumes.
if [ -n "$CT_LOCAL_CONFIG" ]; then
  echo "$CT_LOCAL_CONFIG" > "$CT_CONFIG_DIR/local-config.hcl"
fi

# If the user is trying to run consul-template directly with some arguments, then
# pass them to consul-template.
if [ "${1:0:1}" = '-' ]; then
  set -- /bin/consul-template "$@"
fi

# If we are running Consul, make sure it executes as the proper user.
if [ "$1" = '/bin/consul-template' ]; then

  # Set the configuration directory
  shift
  set -- /bin/consul-template \
    -config="$CT_CONFIG_DIR" \
    "$@"

  # Check the user we are running as
  current_user="$(id -un)"
  if [ "${current_user}" == "root" ]; then
    # Run under the right user
    set -- gosu consul-template "$@"
  fi
fi

exec "$@"
```

### Dockerfile

```Dockerfile
FROM hashicorp/consul-template:0.19.6-dev-alpine

ADD build/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN apk --no-cache add shadow && \
    usermod -u 1000 consul-template && \
    chown -Rc consul-template:consul-template /consul-template/

USER consul-template:consul-template
```

### ConfigMap

```yaml
---
apiVersion: v1
kind: ConfigMap
metadata:
  labels:
    app.kubernetes.io/name: prometheus
    prometheus: consul-template
  name: prometheus-consul-template
data:
  config.hcl: |
    vault {
      ssl {
        ca_cert = "/vault/tls/ca.crt"
      }
      grace = "5m"
      retry {
        backoff = "1s"
      }
    }
    template {
      destination = "/vault/secrets/vault-token"
      command     = "/bin/sh -c '/usr/bin/curl -s http://127.0.0.1:9090/-/reload'"
      contents = <<-EOH
      {{with secret "/auth/token/create/prometheus-metrics" "policy=prometheus-metrics" }}{{.Auth.ClientToken}}{{ end }}
      EOH
      wait {
        min = "2s"
        max = "60s"
      }
    }
```

## Vault CR snippets

Set the vault image to use:

```yaml
---
apiVersion: "vault.banzaicloud.com/v1alpha1"
kind: "Vault"
metadata:
  name: "vault"
spec:
  size: 2
  image: vault:1.1.2
```

Our Vault config for telemetry:

```yaml
  # A YAML representation of a final vault config file.
  # See https://www.vaultproject.io/docs/configuration/ for more information.
  config:
    telemetry:
      prometheus_retention_time: 30s
      disable_hostname: true
```

Disable statsd:

```yaml
  # since we are running Vault 1.1.0 with the native Prometheus support, we do not need the statsD exporter
  statsdDisabled: true
```

Vault externalConfig policies:

```yaml
  externalConfig:
    policies:
      - name: prometheus-operator-prometheus
        rules: |
          path "auth/token/create/prometheus-metrics" {
            capabilities = ["read", "update"]
          }
      - name: prometheus-metrics
        rules: path "sys/metrics" {
          capabilities = ["list", "read"]
          }
```

auth:

```yaml
    auth:
      - type: token
        roles:
          - name: prometheus-metrics
            allowed_policies:
              - prometheus-metrics
            orphan: true
      - type: kubernetes
        roles:
          - name: prometheus-operator-prometheus
            bound_service_account_names: prometheus-operator-prometheus
            bound_service_account_namespaces: mynamespace
            policies: prometheus-operator-prometheus
            ttl: 4h
```

## Prometheus Operator Snippets

### prometheusSpec

```yaml
  prometheusSpec:
    # https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#prometheusspec
    podMetadata:
      annotations:
        vault.security.banzaicloud.io/vault-ct-configmap: "prometheus-consul-template"
        vault.security.banzaicloud.io/vault-role: prometheus-operator-prometheus
        vault.security.banzaicloud.io/vault-ct-image: "mycustomimage:latest"

    secrets:
      - etcd-client-tls
      - vault-tls
```

### Prometheus CRD ServiceMonitor

```yaml
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    app.kubernetes.io/name: vault
    app.kubernetes.io/instance: prometheus-operator
  name: prometheus-operator-vault
spec:
  endpoints:
    - bearerTokenFile: /vault/secrets/vault-token
      interval: 30s
      params:
        format: ['prometheus']
      path: /v1/sys/metrics
      port: api-port
      scheme: https
      tlsConfig:
        caFile: /etc/prometheus/secrets/vault-tls/ca.crt
        certFile: /etc/prometheus/secrets/vault-tls/server.crt
        keyFile: /etc/prometheus/secrets/vault-tls/server.key
        insecureSkipVerify: true
  selector:
    matchLabels:
      app.kubernetes.io/name: vault
      vault_cr: vault
```
