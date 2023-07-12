---
title: Getting started
weight: 10
---

Bank-Vaults is a swiss-army knife with multiple manifestations, so the first steps depend on what you want to achieve.
Check one of the following guides to get an overview:

- [Dynamic credentials with Vault using Kubernetes Service Accounts](https://techblog.cisco.com/vault-dynamic-secrets/)
- [Vault Operator](https://techblog.cisco.com/vault-operator/)
- [Vault unseal flow with KMS](https://techblog.cisco.com/vault-unsealing/)
- [Monitoring Vault on Kubernetes using Cloud Native technologies](https://techblog.cisco.com/monitoring-vault-grafana/)
- [Inject secrets directly into pods from Vault](https://techblog.cisco.com/inject-secrets-into-pods-vault-revisited/)

## Deploy with Helm

We have some fully fledged, production-ready Helm charts for deploying:

- [Vault](https://github.com/bank-vaults/bank-vaults/tree/master/charts/vault) using `bank-vaults`,
- the [Vault Operator](https://github.com/bank-vaults/bank-vaults/tree/master/charts/vault-operator), and also
- the [Vault Secrets Webhook](https://github.com/bank-vaults/bank-vaults/tree/master/charts/vault-secrets-webhook).

With the help of these charts you can run a HA Vault instance with automatic initialization, unsealing, and external configuration which would otherwise be a tedious manual operation. Also secrets from Vault can be injected into your Pods directly as environment variables (without using Kubernetes Secrets). These charts can be used easily for development purposes as well.

> Note: Starting with Bank-Vaults version 1.6.0, only Helm 3 is supported. If you have installed the chart with Helm 2 and now you are trying to upgrade with Helm3, see the [Bank-Vaults 1.6.0 release notes](https://github.com/bank-vaults/bank-vaults/releases/tag/1.6.0) for detailed instructions.

{{< include-headless "deploy-operator-local.md" >}}

{{< include-headless "deploy-mutating-webhook.md" >}}

## Install the CLI tool

On macOs, you can directly install the CLI from Homebrew:

```bash
brew install banzaicloud/tap/bank-vaults
```

Alternatively, fetch the source code and compile it using go get:

```bash
go get github.com/bank-vaults/bank-vaults/cmd/bank-vaults
go get github.com/bank-vaults/bank-vaults/cmd/vault-env
```

## Docker images

If you want to build upon our Docker images, you can find them on Docker Hub:

```bash
docker pull banzaicloud/bank-vaults
docker pull banzaicloud/vault-operator
docker pull banzaicloud/vault-env
```
