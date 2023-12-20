---
title: Licensing guide
weight: 1275
---

This guide explains the licensing of the different Bank-Vaults components, and how they are affected by the [HashiCorp Vault license](https://www.hashicorp.com/bsl).

Bank-Vaults interfaces with Vault in several ways:

- The [Bank-Vaults CLI]({{< relref "/docs/cli-tool/_index.md" >}}) streamlines Vault configuration.
- The [Vault Operator]({{< relref "/docs/operator/_index.md" >}}) enables seamless operation of Vault on Kubernetes.
- The [Vault Secrets Webhook]({{< relref "/docs/mutating-webhook/_index.md" >}}) can directly inject secrets from Vault into Kubernetes pods.

The Bank-Vaults CLI and the Vault Secrets Webhook are not affected by the HashiCorp licensing changes, you can use them both with the older MPL-licensed versions of Vault, and also the newer BUSL-licensed versions.

- By default, the Bank-Vaults components are licensed under the [Apache 2.0 License](https://github.com/bank-vaults/bank-vaults/blob/main/LICENSE).
- The license of the Vault operator and our Vault Helm chart might change to BUSL in the near future to meet the terms of the Vault BUSL license. We are waiting on our legal advisors to decide wether this change is necessary.
- Each component includes a LICENSE file in its repository to make it obvious which license applies to the component.

If you are using the Vault operator or our Vault Helm chart in a scenario that requires a commercial Vault license, obtaining it is your responsibility.
