---
title: Deploy vault into a custom namespace
shorttitle: Custom namespace
---

To deploy vault into a custom namespace (not into `default`), you have to deploy the vault CustomResource to the custom namespace. Also, you have to use the custom namespace in the following fields:

In the RBAC resources:

- [subjects.namespace of the ClusterRoleBinding](https://github.com/banzaicloud/bank-vaults/blob/master/operator/deploy/rbac.yaml#L49)

In the Vault CR:

- [unsealConfig.kubernetes.secretNamespace](https://github.com/banzaicloud/bank-vaults/blob/master/operator/deploy/cr.yaml#L101)
- [secrets.configuration.config.issuing_certificates and crl_distribution_points:](https://github.com/banzaicloud/bank-vaults/blob/master/operator/deploy/cr.yaml#L155-L157)
