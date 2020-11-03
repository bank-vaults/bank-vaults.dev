---
title: Overview
weight: 5
---

{{% include-headless "doc/bank-vaults-intro.md" %}}

Bank-Vaults provides the following tools for Hashicorp Vault to make its use easier and more automated:

- A [Kubernetes operator for provisioning secrets](/docs/bank-vaults/operator/).
- A [mutating webhook for injecting secrets](/docs/bank-vaults/mutating-webhook/).
- A [CLI tool](/docs/bank-vaults/cli-tool/) to automatically initialize, unseal, and configure Vault with authentication methods and secret engines.
- A [Go client wrapper](/docs/bank-vaults/go-library/) for the official Vault client with automatic token renewal, built-in Kubernetes support, and a dynamic database credential provider.

![Bank-Vaults overview](/docs/bank-vaults/images/bank-vault-overview.png)

The package also includes Helm charts for installing the various components, and a collection of scripts to support advanced features (for example, dynamic SSH).

## First step

If you are new to **Bank-Vaults**, begin with the [getting started guide]({{<relref "installing">}}).
You can also <a href="https://github.com/banzaicloud/bank-vaults" target="_blank">view the Github repository</a>, the [Bank-Vaults related blogposts](/tags/vault/), or [schedule a demo](/contact/).
