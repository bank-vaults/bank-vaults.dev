---
title: Annotations
weight: 40
---

The mutating webhook adds the following PodSpec, Secret, ConfigMap, and CRD annotations.

|Annotation    |default     |Explanation |
|--------------|------------|------------|
`vault.security.banzaicloud.io/vault-addr`|`"https://vault:8200"`|Same as VAULT_ADDR|
`vault.security.banzaicloud.io/vault-image`|`"vault:latest"`|Vault agent image|
`vault.security.banzaicloud.io/vault-image-pull-policy`|`IfNotPresent`|the Pull policy for the vault agent container|
`vault.security.banzaicloud.io/vault-role`|`""`|The Vault role for Vault agent to use, for Pods it is the name of the ServiceAccount if not specified|
`vault.security.banzaicloud.io/vault-path`|`"kubernetes"`|The mount path of the auth method|
`vault.security.banzaicloud.io/vault-skip-verify`|`"false"`|Same as VAULT_SKIP_VERIFY|
`vault.security.banzaicloud.io/vault-tls-secret`|`""`|Name of the Kubernetes Secret holding the CA certificate for Vault|
`vault.security.banzaicloud.io/vault-ignore-missing-secrets`|`"false"`|When enabled will only log warnings when Vault secrets are missing|
`vault.security.banzaicloud.io/vault-env-passthrough`|`""`|Comma separated list of `VAULT_*` related environment variables to pass through to `vault-env` to the main process. E.g. `VAULT_ADDR,VAULT_ROLE`.|
`vault.security.banzaicloud.io/vault-env-daemon`|`"false"`|Run `vault-env` as a daemon instead of replacing itself with the main process. For details, see {{< relref "/docs/bank-vaults/mutating-webhook/deploy.md#daemon-mode" >}}.|
`vault.security.banzaicloud.io/vault-env-image`|`"banzaicloud/vault-env:latest"`|vault-env image|
`vault.security.banzaicloud.io/vault-env-image-pull-policy`|`IfNotPresent`|the Pull policy for the vault-env container|
`vault.security.banzaicloud.io/mutate-configmap`|`"false"`|Mutate the annotated ConfigMap as well (only Secrets and Pods are mutated by default)|
`vault.security.banzaicloud.io/enable-json-log`|`"false"`|Log in JSON format in `vault-env`|
`vault.security.banzaicloud.io/mutate`|`""`|Defines the mutation of the given resource, possible values: `"skip"` which prevents it.|
`vault.security.banzaicloud.io/vault-env-from-path`|`""`|Comma-delimited list of vault paths to pull in all secrets as environment variables|
`vault.security.banzaicloud.io/token-auth-mount`|`""`|`{volume:file}` to be injected as `.vault-token`. |
`vault.security.banzaicloud.io/inline-mutation`|`"false"`|Enables inline mutation of secrets and configmaps by using `${{vault:secret#field}}` inside a string. For details, see {{< relref "/docs/bank-vaults/mutating-webhook/configuration.md#inline" >}}.|
`vault.security.banzaicloud.io/vault-auth-method`|`"kubernetes"`| The [Vault authentication method](https://www.vaultproject.io/docs/auth) to be used, one of `["kubernetes", "aws-ec2", "gcp-gce", "jwt"]`|
