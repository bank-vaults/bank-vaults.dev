---
title: Mutating Webhook
weight: 300
---

The mutating admission webhook injects (in a very non-intrusive way) an executable into containers of Deployments and StatefulSets. This executable can request secrets from Vault through special environment variable definitions.

## How the webhook works - overview

{{< include-headless "mutating-webhook-config-examples-basic.md" "bank-vaults" >}}

For further examples and use cases, see [Configuration examples and scenarios](/docs/bank-vaults/mutating-webhook/configuration/).

{{< include-headless "deploy-mutating-webhook.md" "bank-vaults" >}}

## Deploy in daemon mode {#daemon-mode}

`vault-env` by default replaces itself with the original process of the Pod after reading the secrets from Vault, but with the `vault.security.banzaicloud.io/vault-env-daemon: "true"` annotation this behavior can be changed. So `vault-env` can change to `daemon mode`, so `vault-env` starts the original process as a child process and remains in memory, and renews the lease of the requested Vault token and of the dynamic secrets (if requested any) until their final expiration time.

A full example can be found in the repository using with MySQL dynamic secrets:

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

## Get secret data from Vault and replace it in Kubernetes Secret (and/or ConfigMap)

You can mutate Secrets (and ConfigMaps) as well if you set annotations and define proper Vault path in the `data` section:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: sample-secret
  annotations:
    vault.security.banzaicloud.io/vault-addr: "https://vault.default.svc.cluster.local:8200"
    vault.security.banzaicloud.io/vault-role: "default"
    vault.security.banzaicloud.io/vault-skip-verify: "true"
    vault.security.banzaicloud.io/vault-path: "kubernetes"
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: eyJhdXRocyI6eyJodHRwczovL2RvY2tlci5pbyI6eyJ1c2VybmFtZSI6InZhdWx0OnNlY3JldC9kYXRhL2RvY2tlcnJlcG8vI0RPQ0tFUl9SRVBPX1VTRVIiLCJwYXNzd29yZCI6InZhdWx0OnNlY3JldC9kYXRhL2RvY2tlcnJlcG8vI0RPQ0tFUl9SRVBPX1BBU1NXT1JEIiwiYXV0aCI6ImRtRjFiSFE2YzJWamNtVjBMMlJoZEdFdlpHOWphMlZ5Y21Wd2J5OGpSRTlEUzBWU1gxSkZVRTlmVlZORlVqcDJZWFZzZERwelpXTnlaWFF2WkdGMFlTOWtiMk5yWlhKeVpYQnZMeU5FVDBOTFJWSmZVa1ZRVDE5UVFWTlRWMDlTUkE9PSJ9fX0=
```

In the example above the secret type is `kubernetes.io/dockerconfigjson` and the webhook can get credentials from Vault.
The base64 encoded data contain vault path in case of username and password for docker repository and you can create it with commands:

```bash
kubectl create secret docker-registry dockerhub --docker-username="vault:secret/data/dockerrepo#DOCKER_REPO_USER" --docker-password="vault:secret/data/dockerrepo#DOCKER_REPO_PASSWORD"
kubectl annotate secret dockerhub vault.security.banzaicloud.io/vault-addr="https://vault.default.svc.cluster.local:8200"
kubectl annotate secret dockerhub vault.security.banzaicloud.io/vault-role="default"
kubectl annotate secret dockerhub vault.security.banzaicloud.io/vault-skip-verify="true"
kubectl annotate secret dockerhub vault.security.banzaicloud.io/vault-path="kubernetes"
```

## Using charts without explicit container.command and container.args

The Webhook is now capable of determining the container's `ENTRYPOINT` and `CMD` with the help of image metadata queried from the image registry, this data is cached until the webhook Pod is restarted. If the registry is publicly accessible (without authentication) you don't need to do anything, but if the registry requires authentication the credentials have to be available in the Pod's `imagePullSecrets` section.

Some examples (apply `cr.yaml` from the operator samples first):

```bash
helm upgrade --install mysql stable/mysql \
  --set mysqlRootPassword=vault:secret/data/mysql#MYSQL_ROOT_PASSWORD \
  --set mysqlPassword=vault:secret/data/mysql#MYSQL_PASSWORD \
  --set "podAnnotations.vault\.security\.banzaicloud\.io/vault-addr"=https://vault:8200 \
  --set "podAnnotations.vault\.security\.banzaicloud\.io/vault-tls-secret"=vault-tls
```

### Registry access

You can also specify a default secret being used by the webhook for cases where a pod has no `imagePullSecrets` specified. To make this work you have to set the environment variables `DEFAULT_IMAGE_PULL_SECRET` and `DEFAULT_IMAGE_PULL_SECRET_NAMESPACE` when deploying the vault-secrets-webhook. Have a look at the values.yaml of the
[vault-secrets-webhook](https://github.com/banzaicloud/bank-vaults/blob/master/charts/vault-secrets-webhook/values.yaml) helm chart to see how this is done.

**NOTE**: _If you EC2 nodes are having ECR instance role added the webhook can request an ECR access token through that role automatically, instead of an explicit `imagePullSecret`_

Future improvements:

- on Azure/Alibaba and GKE get a credential dynamically with the specific SDK (for AWS ECR this is already done)

When using a private image repository:

```bash
# Docker Hub

kubectl create secret docker-registry dockerhub --docker-username=${DOCKER_USERNAME} --docker-password=$DOCKER_PASSWORD

helm upgrade --install mysql stable/mysql --set mysqlRootPassword=vault:secret/data/mysql#MYSQL_ROOT_PASSWORD --set "imagePullSecrets[0].name=dockerhub" --set-string "podAnnotations.vault\.security\.banzaicloud\.io/vault-skip-verify=true" --set image="private-repo/mysql"

# GCR

kubectl create secret docker-registry gcr \
--docker-server=gcr.io \
--docker-username=_json_key \
--docker-password="$(cat ~/json-key-file.json)"

helm upgrade --install mysql stable/mysql --set mysqlRootPassword=vault:secret/data/mysql#MYSQL_ROOT_PASSWORD --set "imagePullSecrets[0].name=gcr" --set-string "podAnnotations.vault\.security\.banzaicloud\.io/vault-skip-verify=true" --set image="gcr.io/your-repo/mysql"

# ECR

TOKEN=`aws ecr --region=eu-west-1 get-authorization-token --output text --query authorizationData[].authorizationToken | base64 --decode | cut -d: -f2`

kubectl create secret docker-registry ecr \
 --docker-server=https://171832738826.dkr.ecr.eu-west-1.amazonaws.com \
 --docker-username=AWS \
 --docker-password="${TOKEN}"

 helm upgrade --install mysql stable/mysql --set mysqlRootPassword=vault:secret/data/mysql#MYSQL_ROOT_PASSWORD --set "imagePullSecrets[0].name=ecr" --set-string "podAnnotations.vault\.security\.banzaicloud\.io/vault-skip-verify=true" --set image="171832738826.dkr.ecr.eu-west-1.amazonaws.com/mysql" --set-string imageTag=5.7
```
