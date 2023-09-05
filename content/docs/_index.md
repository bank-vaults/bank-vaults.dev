---
title: Documentation
weight: 5
aliases:
- /docs/overview/
---

{{% include-headless "bank-vaults-intro.md" %}}

Bank-Vaults provides the following tools for Hashicorp Vault to make its use easier and more automated:

- A [Kubernetes operator for provisioning secrets]({{< relref "/docs/operator/_index.md" >}}).
- A [mutating webhook for injecting secrets]({{< relref "/docs/mutating-webhook/_index.md" >}}).
- A [CLI tool]({{< relref "/docs/cli-tool/_index.md" >}}) to automatically initialize, unseal, and configure Vault with authentication methods and secret engines.
- A [Go client wrapper]({{< relref "/docs/go-library/_index.md" >}}) for the official Vault client with automatic token renewal, built-in Kubernetes support, and a dynamic database credential provider.

![Bank-Vaults overview](/docs/images/bank-vault-overview.png)

The package also includes Helm charts for installing the various components, and a collection of scripts to support advanced features (for example, dynamic SSH).

{{% include-remote-mdsnippet "https://github.com/bank-vaults/vault-operator/raw/main/VERSIONS.md" %}}

## First step

- If you are new to **Bank-Vaults**, begin with the [getting started guide]({{<relref "installing">}}).
- If you need help using Bank-Vaults, see the [Support page]({{< relref "/docs/support.md" >}}) for ways to contact us.
