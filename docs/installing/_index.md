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

### Deploy a local Vault operator

This is the simplest scenario: you install the Vault operator on a simple cluster. The following commands install a single-node Vault instance that stores unseal and root tokens in Kubernetes secrets.

1. Install the Bank-Vaults operator:

    ```bash
    helm repo add banzaicloud-stable https://kubernetes-charts.banzaicloud.com
    helm upgrade --install vault-operator banzaicloud-stable/vault-operator
    ```

1. Create a Vault instance using the Vault custom resources. This will create a Kubernetes `CustomResource` called `vault` and a PersistentVolumeClaim for it:

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/banzaicloud/bank-vaults/master/operator/deploy/rbac.yaml
    kubectl apply -f https://raw.githubusercontent.com/banzaicloud/bank-vaults/master/operator/deploy/cr.yaml
    ```

1. Wait a few seconds, then check the operator and the vault pods:

    ```bash
    kubectl get pods

    NAME                                                        READY     STATUS    RESTARTS   AGE
    vault-66f484898d-lbltm                                      2/2       Running   0          10s
    vault-configurer-6c545cb6b4-dmvb5                           1/1       Running   0          10s
    vault-operator-788559bdc5-kgqkg                             1/1       Running   0          23s
    ```

1. For other configuration examples of the Vault CustomResource, see the YAML files in the [operator/deploy directory of the project](https://github.com/banzaicloud/bank-vaults/tree/master/operator/deploy) (we use these for testing), and our various [blog posts](/tags/bank-vaults/). After you are done experimenting with Bank-Vaults and you want to delete the operator, you can delete the related CRs:

    ```bash
    kubectl delete -f https://raw.githubusercontent.com/banzaicloud/bank-vaults/master/operator/deploy/rbac.yaml
    kubectl delete -f https://raw.githubusercontent.com/banzaicloud/bank-vaults/master/operator/deploy/cr.yaml
    ```

### Deploy the mutating webhook

You can deploy the Vault Secrets Webhook using Helm. Note that:

- The Helm chart of the vault-secrets-webhook contains the templates of the required permissions as well.
- The deployed RBAC objects contain the necessary permissions fo running the webhook.

#### Prerequisites

- The user you use for deploying the chart to the Kubernetes cluster must have cluster-admin privileges.
- The chart requires Helm 3.
- To interact with Vault (for example, for testing), the *vault* command line client must be installed on your computer.

#### Deploy the webhook

1. Create a namespace for the webhook and add a label to the namespace, for example, *vault-infra*:

    ```bash
    kubectl create namespace vault-infra
    kubectl label namespace vault-infra name=vault-infra
    ```

1. Deploy the vault-secrets-webhook chart:

    ```bash
    helm repo add banzaicloud-stable https://kubernetes-charts.banzaicloud.com
    helm upgrade --namespace vault-infra --install vault-secrets-webhook banzaicloud-stable/vault-secrets-webhook
    ```

1. Check that the pods are running:

    ```bash
    kubectl get pods --namespace vault-infra
    NAME                                     READY   STATUS    RESTARTS   AGE
    vault-secrets-webhook-58b97c8d6d-qfx8c   1/1     Running   0          22s
    vault-secrets-webhook-58b97c8d6d-rthgd   1/1     Running   0          22s
    ```

1. Write a secret into Vault (the Vault CLI must be installed on your computer):

    ```bash
    vault kv put secret/demosecret/aws AWS_SECRET_ACCESS_KEY=s3cr3t
    ```

1. Apply the following deployment to your cluster. The webhook will mutate this deployment because it has an environment variable having a value which is a reference to a path in Vault:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vault-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: vault
  template:
    metadata:
      labels:
        app.kubernetes.io/name: vault
      annotations:
        vault.security.banzaicloud.io/vault-addr: "https://vault:8200" # optional, the address of the Vault service, default values is https://vault:8200
        vault.security.banzaicloud.io/vault-role: "default" # optional, the default value is the name of the ServiceAccount the Pod runs in, in case of Secrets and ConfigMaps it is "default"
        vault.security.banzaicloud.io/vault-skip-verify: "false" # optional, skip TLS verification of the Vault server certificate
        vault.security.banzaicloud.io/vault-tls-secret: "vault-tls" # optinal, the name of the Secret where the Vault CA cert is, if not defined it is not mounted
        vault.security.banzaicloud.io/vault-agent: "false" # optional, if true, a Vault Agent will be started to do Vault authentication, by default not needed and vault-env will do Kubernetes Service Account based Vault authentication
        vault.security.banzaicloud.io/vault-path: "kubernetes" # optional, the Kubernetes Auth mount path in Vault the default value is "kubernetes"
    spec:
      serviceAccountName: default
      containers:
      - name: alpine
        image: alpine
        command: ["sh", "-c", "echo $AWS_SECRET_ACCESS_KEY && echo going to sleep... && sleep 10000"]
        env:
        - name: AWS_SECRET_ACCESS_KEY
          value: vault:secret/data/demosecret/aws#AWS_SECRET_ACCESS_KEY
```

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
