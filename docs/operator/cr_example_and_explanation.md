---
title: Operator Configuration for Functioning Webhook Secrets Mutation
weight: 200
---

One can find several examples of the vault operator CR manifest in
[1][this directory]. This document only uses the [2][following vanilla CR]
to demonstrate some main points about how to properly configure the
operator for secrets mutations to function.

This document does not attempt to explain every possible scnario with respect to
the CRs in the aforementioned directory, but instead attempts to explain at
a high level of important aspects of CR so that the reader can determine on the
reader's own how best to configure one's operator.

## High Points

Some important aspects of the operator and its configuration with respect to secrets
mutation are:

  * The vault operator instantiates
    * the vault configurer pod(s)
    * the vault pod(s)
    * the vault-secrets-webhook pod(s)
  * The vault configurer
    * unseals the vault
    * configures vault with policies, roles, etc
  * vault-secrets-webhook does nothing more than:
    * monitors cluster for resources with specific annotations for secrets injection and
    * integrates with vault API to answer secrets requests from those resources for
      requested secrets
    * for pods using environment secrets, inject a binary `vault-env` into pods
      and updates ENTRYPOINT to run `vault-env CMD` instead of `CMD`.
      `vault-env` intercepts requests for env secrets requests during runtime of
      pod and upon such requests makes vault API call for requested secret
      injecting secret into environment variable so `CMD` works with proper
      secrets.
  * Vault
    * the secrets workhorse
    * surfaces a RESTful API for secrets management

## CR configuration properties

This section will go over some important properties of the CR and their purpose:

### Vault's service account

This is the serviceaccount  where Vault will be running. The Configurer will run
in the same namespace and should have the same service account. The operator
will assign this serviceaccount to Vault.

```yaml
  # Specify the ServiceAccount where the Vault Pod and the Bank-Vaults configurer/unsealer is running
  serviceAccount: vault
```

### caNamespaces

In order for vault communication to be encrypted, valid TLS certificates need to
be used. The following property will automatically create TLS certs secrets for
the namespaces specified here. Notice that this is a list, so one can either
specify multiple namespaces per line or use the splat or wildcard asterisk to
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
        # Uncommenting the following line and deleting tls_cert_file and tls_key_file disables TLS
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

### Relationships

The following will simply go "down the line" of the example above.

#### externalConfig

The `externalConfig` portion _of this CR example_ correlates to [4][kubernetes
configuration] as specified by `.auth[].type`.

This YAML representation of configuration is flexible enough to work with any
auth methods available to Vault as documented [4][in the Vault documentation].
For now, we'll stick with this kubernetes configuration.

#### externalConfig.policies

Correlates 1:1 to the creation of the specified policy in conjunction with [5][Vault
policies]

#### externalConfig.auth[].type

`- type: kubernetes` - specifies to configure Vault for use [4][with Kubernetes
authentication]

[3][Other types] are yet to be documented with respect to the operator
configuration.

#### externalConfig.auth[].roles[]

correlates to [6][creating kubernetes roles]. Some important nuances here are:

  * Vault does not respect inline secrets serviceaccount annotations, so the
    namespace of any serviceaccount annotations for secrets are irrelevant to
    getting inline secrets mutations functioning...
  * instead, the serviceaccount of the vault-secrets-webhook pod(s) should be
    used to configure the `bound_service_account_names` and
    `bound_service_account_namespaces` for inline secrets to mutate.
  * Pod serviceaccounts, however, are respected so
    `bound_service_account_namespaces` and `bound_service_account_names` for
    environment mutations must identify such of the running pods.

One will notice that there are two roles specified in the YAML example above;
one for pods and one for inline secrets mutations. While this was not strictly
required, it makes for cleaner implementation.

[1]:https://github.com/banzaicloud/bank-vaults/blob/master/operator/deploy
[2]:https://github.com/banzaicloud/bank-vaults/blob/master/operator/deploy/cr.yaml
[3]:https://www.vaultproject.io/api/auth
[4]:https://www.vaultproject.io/api/auth/kubernetes#configure-method
[5]:https://www.vaultproject.io/api-docs/system/policy
[6]:https://www.vaultproject.io/api/auth/kubernetes#create-role
