---
title: Upgrade Vault with the Bank-Vaults operator
linktitle: Upgrade Vault
weight: 50
---

To upgrade Vault using the Bank-Vaults operator, complete the following steps.

1. Check the release notes of Vault for any special upgrade instructions. Usually there are no instructions, but it's better to be safe than sorry.
1. [Adjust the spec.image in field in the Vault custom resource](https://github.com/bank-vaults/vault-operator/blob/main/deploy/examples/cr.yaml#L7).
1. The Bank-Vaults operator updates the statefulset. (It does not take the HA leader into account in HA scenarios, but this has never caused any issues so far.)
