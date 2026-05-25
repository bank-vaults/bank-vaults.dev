---
title: Upgrade strategies
weight: 50
aliases:
- /docs/operator/upgrade-vault/
---

## Upgrade Vault

To upgrade the Vault, complete the following steps.

1. Check the [release notes of Vault](https://developer.hashicorp.com/vault/docs/updates/release-notes) for any special upgrade instructions. Usually there are no instructions, but it's better to be safe than sorry.
1. Adjust the [spec.image field in the Vault custom resource](https://github.com/bank-vaults/vault-operator/blob/v{{< param "latest_vault_operator" >}}/deploy/examples/cr.yaml#L7). If you are using the Vault Helm chart, adjust the [image.tag field in the values.yaml](https://github.com/bank-vaults/vault-helm-chart/blob/v{{< param "latest_vault_helm_chart" >}}/vault/values.yaml#L13).
1. The Vault Helm chart updates the StatefulSet. It does not take the HA leader into account in HA scenarios, but this has never caused any issues so far.

## Upgrade Vault operator

### v1.24.0 upgrade guide

Adds support for **HashiCorp Vault 2.0.x**. Bumps the minimum bank-vaults CLI image
to **v1.33.1**. Existing Vault 1.x deployments continue to work — no spec changes
required on upgrade.

The operator handles Vault 2.0 behavior changes automatically:

- **Auto `disable_mlock: true`** when the field is unset and the Vault image needs it
  (2.0.0 across all backends; 2.0.1+ with raft storage). Explicit user values are
  preserved.
- **Auto `VAULT_API_ADDR`** on the vault container, silencing the *"no api_addr
  value specified"* warning.
- **New `spec.skipEntrypointSetup` field** (`*bool`). Sets `SKIP_CHOWN=true` /
  `SKIP_SETCAP=true` to bypass the hashicorp/vault docker-entrypoint steps that
  fail under Kubernetes. Default (`nil`) only enables this for Vault 2.0.0 (the
  only version where the chown is fatal); set to `true`/`false` to override.
- **`IPC_LOCK` + `SETFCAP` always granted**, regardless of `disable_mlock` —
  Vault 2.0's entrypoint refuses to exec without `IPC_LOCK`.

Examples under `deploy/examples/cr-raft*.yaml`, `cr-hsm-*.yaml`, and the multi-DC
samples now set `disable_mlock: true` explicitly. Adding it to your CRs is
recommended for clarity but not required.

```bash
helm upgrade vault-operator oci://ghcr.io/bank-vaults/helm-charts/vault-operator \
	--set image.tag=v1.24.0 \
	--set bankVaults.image.tag=v1.33.1 \
	--wait
```

### v1.20.0 upgrade guide

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
