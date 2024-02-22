---
title: Getting started
weight: 10
---

Bank-Vaults is a swiss-army knife with multiple manifestations, so the first steps depend on what you want to achieve.
<!-- Check one of the following guides to get an overview:

- [Dynamic credentials with Vault using Kubernetes Service Accounts](https://techblog.cisco.com/vault-dynamic-secrets/)
- [Vault Operator](https://techblog.cisco.com/vault-operator/)
- [Vault unseal flow with KMS](https://techblog.cisco.com/vault-unsealing/)
- [Inject secrets directly into pods from Vault](https://techblog.cisco.com/inject-secrets-into-pods-vault-revisited/) -->

## Deploy with Helm

We have some fully fledged, production-ready Helm charts for deploying:

- [Vault](https://github.com/bank-vaults/vault-helm-chart/tree/main/vault) using `bank-vaults`,
- the [Vault Operator](https://github.com/bank-vaults/vault-operator/tree/main/deploy/charts/vault-operator), and also
- the [Vault Secrets Webhook](https://github.com/bank-vaults/vault-secrets-webhook/tree/main/deploy/charts/vault-secrets-webhook).

With the help of these charts you can run a HA Vault instance with automatic initialization, unsealing, and external configuration which would otherwise be a tedious manual operation. Also secrets from Vault can be injected into your Pods directly as environment variables (without using Kubernetes Secrets). These charts can be used easily for development purposes as well.

> Note: Starting with Bank-Vaults version 1.6.0, only Helm 3 is supported.

{{< include-headless "deploy-operator-local.md" >}}

{{< include-headless "deploy-mutating-webhook.md" >}}

## Install the CLI tool

You can download the `bank-vaults` CLI from the [Bank-Vaults releases page](https://github.com/bank-vaults/bank-vaults/releases). Select the binary for your platform from the **Assets** section for the version you want to use.

<!-- On macOs, you can directly install the CLI from Homebrew:

```bash
brew install banzaicloud/tap/bank-vaults
``` -->

Alternatively, fetch the source code and compile it using go get:

```bash
go get github.com/bank-vaults/bank-vaults/cmd/bank-vaults
go get github.com/bank-vaults/bank-vaults/cmd/vault-env
```

## Docker images

If you want to build upon our Docker images, you can find them on Docker Hub:

```bash
docker pull ghcr.io/bank-vaults/vault-operator:latest
docker pull ghcr.io/bank-vaults/vault-env:latest
```
