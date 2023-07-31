---
title: Upgrade Vault
linktitle: Upgrade Vault
weight: 50
---

To upgrade Vault, complete the following steps.

1. Check the [release notes of Vault](https://developer.hashicorp.com/vault/docs/release-notes) for any special upgrade instructions. Usually there are no instructions, but it's better to be safe than sorry.
1. Adjust the [spec.image field in the Vault custom resource](https://github.com/bank-vaults/vault-operator/blob/v{{< param "latest_version" >}}/deploy/examples/cr.yaml#L7). If you are using the Vault Helm chart, adjust the [image.tag field in the values.yaml](https://github.com/bank-vaults/vault-helm-chart/blob/v{{< param "latest_version" >}}/vault/values.yaml#L13).
1. The Bank-Vaults operator (or the Vault Helm chart) updates the StatefulSet. (It does not take the HA leader into account in HA scenarios, but this has never caused any issues so far.)
