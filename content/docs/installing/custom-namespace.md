---
title: Deploy vault into a custom namespace
linktitle: Custom namespace
---

To deploy vault into a custom namespace (not into `default`), you have to deploy the vault CustomResource to the custom namespace. Also, you have to use the custom namespace in the following fields in the Vault CR:

- [unsealConfig.kubernetes.secretNamespace](https://github.com/bank-vaults/vault-operator/blob/main/deploy/examples/cr.yaml#L116)
- [config.api_addr](https://github.com/bank-vaults/vault-operator/blob/main/deploy/examples/cr-raft.yaml#L144)
- [auth.roles.bound_service_account_namespaces](https://github.com/bank-vaults/vault-operator/blob/main/deploy/examples/cr-raft.yaml#L177)
- [secrets.configuration.config.issuing_certificates and crl_distribution_points](https://github.com/bank-vaults/vault-operator/blob/main/deploy/examples/cr.yaml#L194-L195)
- [secrets.configuration.root/generate.common_name](https://github.com/bank-vaults/vault-operator/blob/main/deploy/examples/cr.yaml#L198)

If not using CRDs, you have to use the custom namespace in the following fields of the Vault Helm chart:

- [vault.externalConfig.auth.roles.bound_service_account_namespaces](https://github.com/bank-vaults/vault-helm-chart/blob/main/vault/values.yaml#L184)
- [unsealer.args](https://github.com/bank-vaults/vault-helm-chart/blob/main/vault/values.yaml#L260)
