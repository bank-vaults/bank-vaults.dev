---
title: The Go library
linktitle: Go library
weight: 800
---

The [vault-sdk repository](https://github.com/bank-vaults/vault-sdk) contains several Go packages for interacting with Vault, these packages are organized into the `sdk` Go module, which can be pulled in with `go get github.com/bank-vaults/vault-sdk/` and is versioned by the `vX.Y.Z` Git tags:

- [auth](https://github.com/bank-vaults/vault-sdk/tree/main/auth): Stores JWT bearer tokens in Vault.

    > Note: The Gin handler is available at [gin-utilz](https://github.com/banzaicloud/gin-utilz/tree/master/auth)

    ![authn](authn-vault-flow.png)

- [vault](https://github.com/bank-vaults/vault-sdk/tree/main/vault): A wrapper for the official Vault client with automatic token renewal, and Kubernetes support.

    ![token](token-request-vault-flow.png)

- [db](https://github.com/bank-vaults/vault-sdk/tree/main/db): A helper for creating database source strings (MySQL/PostgreSQL) with database credentials dynamically based on configured Vault roles (instead of `username:password`).

    ![token](vault-mySQL.gif)

- [tls](https://github.com/bank-vaults/vault-sdk/tree/main/tls): A simple package to generate self-signed TLS certificates. Useful for bootstrapping situations, when you can't use Vault's [PKI secret engine](https://www.vaultproject.io/docs/secrets/pki/index.html).

## Examples for using the library part

Some examples are in `cmd/examples/main.go` of the [vault-operator](https://github.com/bank-vaults/vault-operator/) repository.

- [Vault client example](https://github.com/bank-vaults/vault-operator/blob/main/cmd/examples/main.go#L28)
- [Dynamic secrets for MySQL example with Gorm](https://github.com/bank-vaults/vault-operator/blob/main/cmd/examples/main.go#L69)
- [JWTAuth tokens example with a Gin middleware](https://github.com/bank-vaults/vault-operator/blob/main/cmd/examples/main.go)
