---
title: Tips and tricks
weight: 1150
---

The following section lists some questions, problems, and tips that came up on the [Bank-Vaults Slack channel](https://pages.banzaicloud.com/invite-slack).

## Deploy the webhook from a private registry

If you are getting the **x509: certificate signed by unknown authority app=vault-secrets-webhook** error when the webhook is trying to download the manifest from a private image registry, you can:

- Build a docker image where the CA store of the OS layer of the image contains the CA certificate of the registry.
- Alternatively, you can disable certificate verification for the registry by using the **REGISTRY_SKIP_VERIFY="true"** environment variable in the deployment of the webhook.

## Mutate ENV passed to a liveness or readiness probe

To mutate the ENV passed to a liveness or readiness probe, just put /vault/vault-env before /bin/sh, for example:

```yaml
livenessProbe:
  exec:
    command:
    - /vault/vault-env
    - sh
    - -c
    - {{command-to-run}}
```

## Login to the Vault web UI

To login to the Vault web UI, you can use the root token, or any configured authentication backend.

## Can changing the vault CR delete the Vault instance and data?

Bank-Vaults never ever deletes the Vault instance from the cluster. However, if you delete the Vault CR, then the Kubernetes garbage controller deletes the vault pods. You are recommended to [keep backups](/docs/bank-vaults/backup/).

## Set default for vault.security.banzaicloud.io/vault-addr

You can set the default settings for `vault.security.banzaicloud.io/vault-addr` so you don't have to specify it in every PodSpec. Just set the VAULT_ADDR in the env section: [https://github.com/banzaicloud/bank-vaults/blob/3c89e831bdb21b2733680f13ceec7ac4b6e3f892/charts/vault-secrets-webhook/values.yaml#L37](https://github.com/banzaicloud/bank-vaults/blob/3c89e831bdb21b2733680f13ceec7ac4b6e3f892/charts/vault-secrets-webhook/values.yaml#L37)