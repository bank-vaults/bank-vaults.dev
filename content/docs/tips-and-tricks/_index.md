---
title: Tips and tricks
weight: 1150
---

The following section lists some questions, problems, and tips that came up on the [Bank-Vaults Slack channel](https://join.slack.com/t/emergingtechcommunity/shared_invite/zt-1rw2jl0ht-yNdyFgBFlc%7Eyzo9AnE4FbA).

## Login to the Vault web UI

To login to the Vault web UI, you can use the root token, or any configured authentication backend.

## Can changing the vault CR delete the Vault instance and data?

Bank-Vaults never ever deletes the Vault instance from the cluster. However, if you delete the Vault CR, then the Kubernetes garbage controller deletes the vault pods. You are recommended to [keep backups]({{< relref "/docs/backup/_index.md" >}}).

## Set default for vault.security.banzaicloud.io/vault-addr

You can set the default settings for `vault.security.banzaicloud.io/vault-addr` so you don't have to specify it in every PodSpec. Just set the VAULT_ADDR in the env section: [https://github.com/bank-vaults/vault-secrets-webhook/blob/main/deploy/charts/vault-secrets-webhook/values.yaml#L54]https://github.com/bank-vaults/vault-secrets-webhook/blob/main/deploy/charts/vault-secrets-webhook/values.yaml#L54)
