---
title: Mutating Webhook
weight: 300
---

## How the webhook works - overview

Kubernetes secrets are the standard way in which applications consume secrets and credentials on Kubernetes. Any secret that is securely stored in Vault and then unsealed for consumption eventually ends up as a Kubernetes secret. However, despite their name, Kubernetes secrets are not exactly secure, since they are only base64 encoded.

The mutating webhook of Bank-Vaults is a solution that bypasses the Kubernetes secrets mechanism and injects the secrets retrieved from Vault directly into the Pods. Specifically, the mutating admission webhook injects (in a very non-intrusive way) an executable into containers of Deployments and StatefulSets. This executable can request secrets from Vault through special environment variable definitions.

![Kubernetes API requests](/img/blog/vault-webhook/vault-mutating-webhook-revisited.gif)

An important and unique aspect of the webhook is that it is a *daemonless* solution (although if you need it, you can [deploy the webhook in daemon mode](#daemon-mode) as well).

## Why is this more secure than using Kubernetes secrets or any other custom sidecar container?

Our solution is particularly lightweight and uses only existing Kubernetes constructs like annotations and environment variables. No confidential data ever persists on the disk or in etcd - not even temporarily. All secrets are stored in memory, and are only visible to the process that requested them. Additionally, there is no persistent connection with Vault, and any Vault token used to read environment variables is flushed from memory before the application starts, in order to minimize attack surface.

If you want to make this solution even more robust, you can disable *kubectl exec*-ing in running containers. If you do so, no one will be able to hijack injected environment variables from a process.

{{< include-headless "mutating-webhook-config-examples-basic.md" "bank-vaults" >}}

For further examples and use cases, see [Configuration examples and scenarios](/docs/bank-vaults/mutating-webhook/configuration/).

{{< include-headless "deploy-mutating-webhook.md" "bank-vaults" >}}

## Deploy in daemon mode {#daemon-mode}

`vault-env` by default replaces itself with the original process of the Pod after reading the secrets from Vault, but with the `vault.security.banzaicloud.io/vault-env-daemon: "true"` annotation this behavior can be changed. So `vault-env` can change to `daemon mode`, so `vault-env` starts the original process as a child process and remains in memory, and renews the lease of the requested Vault token and of the dynamic secrets (if requested any) until their final expiration time.

You can find a full example using MySQL dynamic secrets in the [Bank-Vaults project repository](https://raw.githubusercontent.com/banzaicloud/bank-vaults/master/deploy/test-dynamic-env-vars.yaml):

```bash
# Deploy MySQL first as the Vault storage backend and our application will request dynamic secrets for this database as well:
helm upgrade --install mysql stable/mysql --set mysqlRootPassword=your-root-password --set mysqlDatabase=vault --set mysqlUser=vault --set mysqlPassword=secret --set 'initializationFiles.app-db\.sql=CREATE DATABASE IF NOT EXISTS app;'

# Deploy the vault-operator and the vault-secerts-webhook
kubectl create namespace vault-infra
kubectl label namespace vault-infra name=vault-infra
helm upgrade --namespace vault-infra --install vault-operator banzaicloud-stable/vault-operator
helm upgrade --namespace vault-infra --install vault-secrets-webhook banzaicloud-stable/vault-secrets-webhook

# Create a Vault instance with MySQL storage and a configured dynamic database secrets backend
kubectl apply -f operator/deploy/rbac.yaml
kubectl apply -f operator/deploy/cr-mysql-ha.yaml

# Deploy the example application requesting dynamic database credentials from the above Vault instance
kubectl apply -f deploy/test-dynamic-env-vars.yaml
kubectl logs -f deployment/hello-secrets
```
