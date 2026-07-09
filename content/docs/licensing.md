---
title: Licensing guide
weight: 1275
---

This guide explains the licensing of the Bank-Vaults components and how they interact with the upstream Vault implementation they manage.

## Bank-Vaults components

All Bank-Vaults components are licensed under the [Apache 2.0 License](https://github.com/bank-vaults/bank-vaults/blob/main/LICENSE). Each repository contains its own `LICENSE` file. This applies to:

- The [Bank-Vaults CLI]({{< relref "/docs/cli-tool/_index.md" >}}).
- The [Vault Operator]({{< relref "/docs/operator/_index.md" >}}).
- The [Vault Helm chart](https://github.com/bank-vaults/vault-helm-chart).
- The [Vault Secrets Webhook]({{< relref "/docs/mutating-webhook/_index.md" >}}).

Bank-Vaults does not embed or redistribute Vault, it manages an upstream Vault container image you choose. Whatever license applies to that image applies to the Vault deployment you run.

## Upstream Vault licensing

Vault's license has changed over time:

- **MPL-2.0** for Vault `< 1.14.x`.
- **[BSL 1.1](https://www.hashicorp.com/bsl)** for Vault `>= 1.14.x` and the Vault 2.0 line. The HashiCorp BSL restricts commercial offerings that compete with HashiCorp's managed Vault product; production use of Vault itself is permitted.
- HashiCorp was acquired by IBM in 2025; the BSL-1.1 terms carried over.

If your use case is restricted by Vault's BSL, you have two options:

1. **Stay on an MPL-licensed Vault release** (`< 1.14.x`). Bank-Vaults still supports these — see the [version compatibility matrix](https://github.com/bank-vaults/vault-operator/blob/main/VERSIONS.md).
2. **Use [OpenBao](https://openbao.org/)** — the Linux Foundation MPL-2.0 community fork. Bank-Vaults image references can be pointed at an OpenBao image; the operator's API is unchanged. This path is community-supported and not yet in our CI matrix.

If you need a commercial Vault license to bypass the BSL non-compete, obtaining it from HashiCorp/IBM is your responsibility. Bank-Vaults does not include or imply any Vault license.
