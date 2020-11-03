---
title: Getting started
weight: 10
---

Bank-Vaults is a swiss-army knife with multiple manifestations, so the first steps depend on what you want to achieve.
Check one of the following guides to get an overview:

- [Authentication and authorization of Pipeline users with OAuth2 and Vault](https://banzaicloud.com/blog/oauth2-vault/)
- [Dynamic credentials with Vault using Kubernetes Service Accounts](https://banzaicloud.com/blog/vault-dynamic-secrets/)
- [Dynamic SSH with Vault and Pipeline](https://banzaicloud.com/blog/vault-dynamic-ssh/)
- [Secure Kubernetes Deployments with Vault and Pipeline](https://banzaicloud.com/blog/hashicorp-guest-post/)
- [Vault Operator](https://banzaicloud.com/blog/vault-operator/)
- [Vault unseal flow with KMS](https://banzaicloud.com/blog/vault-unsealing/)
- [Monitoring Vault on Kubernetes using Cloud Native technologies](https://banzaicloud.com/blog/monitoring-vault-grafana/)
- [Inject secrets directly into pods from Vault](https://banzaicloud.com/blog/inject-secrets-into-pods-vault-revisited/)

## Deploy with Helm

We have some fully fledged, production-ready Helm charts for deploying:

- [Vault](https://github.com/banzaicloud/bank-vaults/tree/master/charts/vault) using `bank-vaults`,
- the [Vault Operator](https://github.com/banzaicloud/bank-vaults/tree/master/charts/vault-operator), and also
- the [Vault Secrets Webhook](https://github.com/banzaicloud/bank-vaults/tree/master/charts/vault-secrets-webhook).

With the help of these charts you can run a HA Vault instance with automatic initialization, unsealing, and external configuration which would otherwise be a tedious manual operation. Also secrets from Vault can be injected into your Pods directly as environment variables (without using Kubernetes Secrets). These charts can be used easily for development purposes as well.

> Note: Starting with Bank-Vaults version 1.6.0, only Helm 3 is supported. If you have installed the chart with Helm 2 and now you are trying to upgrade with Helm3, see the [Bank-Vaults 1.6.0 release notes](https://github.com/banzaicloud/bank-vaults/releases/tag/1.6.0) for detailed instructions.

## Install the CLI tool

On macOs, you can directly install the CLI from Homebrew:

```bash
$ brew install banzaicloud/tap/bank-vaults
```

Alternatively, fetch the source code and compile it using go get:

```bash
go get github.com/banzaicloud/bank-vaults/cmd/bank-vaults
go get github.com/banzaicloud/bank-vaults/cmd/vault-env
```

## Docker images

If you want to build upon our Docker images, you can find them on Docker Hub:

```bash
docker pull banzaicloud/bank-vaults
docker pull banzaicloud/vault-operator
docker pull banzaicloud/vault-env
```
