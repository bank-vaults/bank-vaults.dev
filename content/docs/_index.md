---
title: Documentation
weight: 5
aliases:
- /docs/overview/
---

{{% include-headless "bank-vaults-intro.md" %}}

We provide the following tools for Hashicorp Vault to make its usage easier and more automated:

- [bank-vaults CLI]({{< relref "/docs/cli-tool/_index.md" >}}) makes working with Hashicorp Vault easier. For example, it can automatically initialize, unseal, and configure Vault.
- [Vault operator]({{< relref "/docs/operator/_index.md" >}}) is a Kubernetes operator that helps you operate Hashicorp Vault in a Kubernetes environment.
- [Vault secrets webhook]({{< relref "/docs/mutating-webhook/_index.md" >}}) is a mutating webhook for injecting secrets directly into Kubernetes pods, config maps and custom resources.
- [Vault SDK]({{< relref "/docs/go-library/_index.md" >}}) is a Go client wrapper for the official Vault client with automatic token renewal, built-in Kubernetes support, and a dynamic database credential provider. It makes it easier to work with Vault when developing your own Go applications.

![Bank-Vaults overview](/docs/images/bank-vault-overview.png)

In addition, we also provide Helm charts for installing various components, as well as a collection of scripts to support advanced features (for example, dynamic SSH).

{{% include-remote-mdsnippet "https://github.com/bank-vaults/vault-operator/raw/main/VERSIONS.md" %}}

## First step

- If you are new to **Bank-Vaults**, begin with the [getting started guide]({{<relref "installing">}}).
- If you need help using Bank-Vaults, see the [Support page]({{< relref "/docs/support.md" >}}) for ways to contact us.

## Support

If you encounter problems while using Bank-Vaults that the documentation does not address, you can [open an issue](https://github.com/bank-vaults/bank-vaults/issues) or write to us on [Slack]({{< relref "/docs/support.md" >}}).
