---
title: Upgrade strategies
weight: 50
aliases:
- /docs/operator/upgrade-vault/
---

## Upgrade Vault

To upgrade the Vault, complete the following steps.

1. Check the [release notes of Vault](https://developer.hashicorp.com/vault/docs/release-notes) for any special upgrade instructions. Usually there are no instructions, but it's better to be safe than sorry.
1. Adjust the [spec.image field in the Vault custom resource](https://github.com/bank-vaults/vault-operator/blob/v{{< param "latest_operator_version" >}}/deploy/examples/cr.yaml#L7). If you are using the Vault Helm chart, adjust the [image.tag field in the values.yaml](https://github.com/bank-vaults/vault-helm-chart/blob/v{{< param "latest_version" >}}/vault/values.yaml#L13).
1. The Bank-Vaults operator (or the Vault Helm chart) updates the StatefulSet. (It does not take the HA leader into account in HA scenarios, but this has never caused any issues so far.)

## v1.20.0 upgrade guide

The release of the Vault Operator **v1.20.0** marks the beginning of a new chapter in the development of the Bank-Vaults ecosystem, as this is the first release across the project after it has been dissected and migrated from the original `banzaicloud/bank-vaults` repository under its own `bank-vaults` organization. We paid attention to not introduce breaking changes during the process, however, the following changes are now in effect:

- All Helm charts will now be distributed via OCI registry on GitHub.
- All releases will be tagged with `v` prefix, starting from `v1.20.0`.

Upgrade to the new Vault Operator by changing the helm repository to the new OCI registry, and specifying the new version numbers:

```bash
helm upgrade vault-operator oci://ghcr.io/bank-vaults/helm-charts/vault-operator \
	--set image.tag=v1.20.0 \
	--set bankVaults.image.tag=v1.20.0 \
	--wait
```

Make sure to also change the `bank-vaults` image in the Vault CR’s `spec.bankVaultsImage` field to `ghcr.io/bank-vaults/bank-vaults:1.20.x`.
