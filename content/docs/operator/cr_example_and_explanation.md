---
title: Operator Configuration for Functioning Webhook Secrets Mutation
linktitle: Operator and mutating webhook
weight: 100
---

You can find several examples of the vault operator CR manifest in
[the vault-operator repository](https://github.com/bank-vaults/vault-operator/blob/main/deploy/examples/). The following examples use only this [vanilla CR](https://github.com/bank-vaults/vault-operator/blob/v{{< param "latest_version" >}}/deploy/examples/cr.yaml)
to demonstrate some main points about how to properly configure the
operator for secrets mutations to function.

This document does not attempt to explain every possible scenario with respect to
the CRs in the aforementioned directory, but instead attempts to explain at
a high level the important aspects of the CR, so that you can determine how best to configure your operator.

## Main points

Some important aspects of the operator and its configuration with respect to secrets
mutation are:

  * The vault operator instantiates:
    * the vault configurer pod(s),
    * the vault pod(s),
    * the vault-secrets-webhook pod(s).
  * The vault configurer:
    * unseals the vault,
    * configures vault with policies, roles, and so on.
  * vault-secrets-webhook does nothing more than:
    * monitors cluster for resources with specific annotations for secrets injection, and
    * integrates with vault API to answer secrets requests from those resources for
      requested secrets.
    * For pods using environment secrets, it injects a binary `vault-env` into pods
      and updates ENTRYPOINT to run `vault-env CMD` instead of `CMD`.
      `vault-env` intercepts requests for env secrets requests during runtime of
      pod and upon such requests makes vault API call for requested secret
      injecting secret into environment variable so `CMD` works with proper
      secrets.
  * Vault
    * the secrets workhorse
    * surfaces a RESTful API for secrets management

## CR configuration properties

This section goes over some important properties of the CR and their purpose.

### Vault's service account

This is the serviceaccount where Vault will be running. The Configurer runs
in the same namespace and should have the same service account. The operator
assigns this serviceaccount to Vault.

```yaml
  # Specify the ServiceAccount where the Vault Pod and the Bank-Vaults configurer/unsealer is running
  serviceAccount: vault
```

### caNamespaces

In order for vault communication to be encrypted, valid TLS certificates need to
be used. The following property automatically creates TLS certificate secrets for
the namespaces specified here. Notice that this is a list, so you can
specify multiple namespaces per line, or use the splat or wildcard asterisk to
specify all namespaces:

```yaml
  # Support for distributing the generated CA certificate Secret to other namespaces.
  # Define a list of namespaces or use ["*"] for all namespaces.
  caNamespaces:
    - "*"
```

## Vault Config

The following is simply a YAML representation (as the comment says) for the
Vault configuration you want to run. This is the configuration that vault
configurer uses to configure your running Vault:

```yaml
  # A YAML representation of a final vault config file.
  config:
    api_addr: https://vault:8200
    cluster_addr: https://${.Env.POD_NAME}:8201
    listener:
      tcp:
        address: 0.0.0.0:8200
        # Commenting the following line and deleting tls_cert_file and tls_key_file disables TLS
        tls_cert_file: /vault/tls/server.crt
        tls_key_file: /vault/tls/server.key
    storage:
      file:
        path: "${ .Env.VAULT_STORAGE_FILE }"
    ui: true
  credentialsConfig:
    env: ""
    path: ""
    secretName: ""
  etcdSize: 0
  etcdVersion: ""
  externalConfig:
    policies:
      - name: allow_secrets
        rules: path "secret/*" {
          capabilities = ["create", "read", "update", "delete", "list"]
          }
    auth:
      - type: kubernetes
        roles:
          # Allow every pod in the default namespace to use the secret kv store
          - name: default
            bound_service_account_names:
              - external-secrets
              - vault
              - dex
            bound_service_account_namespaces:
              - external-secrets
              - vault
              - dex
              - auth-system
              - loki
              - grafana
            policies:
              - allow_secrets
            ttl: 1h

          # Allow mutation of secrets using secrets-mutation annotation to use the secret kv store
          - name: secretsmutation
            bound_service_account_names:
              - vault-secrets-webhook
            bound_service_account_namespaces:
              - vault-secrets-webhook
            policies:
              - allow_secrets
            ttl: 1h
```

### externalConfig

The `externalConfig` portion of **this CR example** correlates to [Kubernetes
configuration](https://developer.hashicorp.com/vault/api-docs/auth/kubernetes#configure-method) as specified by `.auth[].type`.

This YAML representation of configuration is flexible enough to work with any
auth methods available to Vault as documented [in the Vault documentation](https://developer.hashicorp.com/vault/api-docs/auth/kubernetes#configure-method).
For now, we'll stick with this kubernetes configuration.

### externalConfig.purgeUnmanagedConfig

Delete any configuration that in Vault but not in `externalConfig`. For more details please check
[Purge unmanaged configuration]({{< relref "/docs/external-configuration/purge-unmanaged-configuration.md" >}})

### externalConfig.policies

Correlates 1:1 to the creation of the specified policy in conjunction with [Vault
policies](https://developer.hashicorp.com/vault/api-docs/system/policy).

### externalConfig.auth[].type

`- type: kubernetes` - specifies to configure Vault to use [Kubernetes
authentication](https://developer.hashicorp.com/vault/api-docs/auth/kubernetes#configure-method)

[Other types](https://developer.hashicorp.com/vault/api-docs/auth) are yet to be documented with respect to the operator
configuration.

### externalConfig.auth[].roles[]

Correlates to [Creating Kubernetes roles](https://developer.hashicorp.com/vault/api-docs/auth/kubernetes#create-role). Some important nuances here are:

  * Vault does not respect inline secrets serviceaccount annotations, so the
    namespace of any serviceaccount annotations for secrets are irrelevant to
    getting inline secrets mutations functioning.
  * Instead, the serviceaccount of the vault-secrets-webhook pod(s) should be
    used to configure the `bound_service_account_names` and
    `bound_service_account_namespaces` for inline secrets to mutate.
  * Pod serviceaccounts, however, are respected so
    `bound_service_account_namespaces` and `bound_service_account_names` for
    environment mutations must identify such of the running pods.

> Note: There are two roles specified in the YAML example above: one for pods, and one for inline secrets mutations. While this was not strictly required, it makes for cleaner implementation.
