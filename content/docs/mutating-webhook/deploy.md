---
title: Deploy the webhook
weight: 10
---

{{< include-headless "deploy-mutating-webhook.md" "bank-vaults" >}}

## Deploy the webhook from a private registry

If you are getting the **x509: certificate signed by unknown authority app=vault-secrets-webhook** error when the webhook is trying to download the manifest from a private image registry, you can:

- Build a docker image where the CA store of the OS layer of the image contains the CA certificate of the registry.
- Alternatively, you can disable certificate verification for the registry by using the **REGISTRY_SKIP_VERIFY="true"** environment variable in the deployment of the webhook.

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
