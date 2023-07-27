---
title: Upgrade Vault
linktitle: Upgrade Vault
weight: 50
---

To upgrade Vault, complete the following steps.

1. Check the [release notes of Vault](https://developer.hashicorp.com/vault/docs/release-notes) for any special upgrade instructions. Usually there are no instructions, but it's better to be safe than sorry.
2. Adjust the [spec.image field in the Vault custom resource](https://github.com/bank-vaults/vault-operator/blob/main/deploy/examples/cr.yaml#L7). If you are using the Vault Helm chart, adjust the [image.tag field in the values.yaml](https://github.com/bank-vaults/vault-helm-chart/blob/main/vault/values.yaml#L13).
3. The Bank-Vaults operator (or the Vault Helm chart) updates the statefulset. (It does not take the HA leader into account in HA scenarios, but this has never caused any issues so far.)
