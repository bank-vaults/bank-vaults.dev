---
title: Mutating Webhook
weight: 300
---

The mutating admission webhook injects an executable to containers (in a very non-intrusive way) inside a Deployments/StatefulSets which than can request secrets from Vault through special environment variable definitions. The project is inspired by many, already existing projects (e.g.: `channable/vaultenv`, `hashicorp/envconsul`). The webhook checks if a container has environment variables defined in the following form, and reads the values for those variables directly from Vault during startup time:

```yaml
        env:
        - name: AWS_SECRET_ACCESS_KEY
          value: vault:secret/data/accounts/aws#AWS_SECRET_ACCESS_KEY
# or
        - name: AWS_SECRET_ACCESS_KEY
          valueFrom:
            secretKeyRef:
              name: aws-key-secret
              key: AWS_SECRET_ACCESS_KEY
# or
        - name: AWS_SECRET_ACCESS_KEY
            valueFrom:
              configMapKeyRef:
                name: aws-key-configmap
                key: AWS_SECRET_ACCESS_KEY
```

The webhook checks if a container has envFrom and parses defined ConfigMaps and Secrets:

```yaml
        envFrom:
          - secretRef:
              name: aws-key-secret
# or
          - configMapRef:
              name: aws-key-configmap
```

Secret and ConfigMap examples:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: aws-key-secret
data:
  AWS_SECRET_ACCESS_KEY: vault:secret/data/accounts/aws#AWS_SECRET_ACCESS_KEY
type: Opaque
```

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-key-configmap
data:
  AWS_SECRET_ACCESSKEY: vault:secret/data/accounts/aws#AWS_SECRET_ACCESS_KEY
```

Also, the webhook can inject into any kind of resources as well (even into CRDs):

```yaml
apiVersion: mysql.example.github.com/v1
kind: MySQLCluster
metadata:
  name: "my-cluster"
spec:
  caBundle: "vault:pki/cert/43138323834372136778363829719919055910246657114#ca"
```

Inline mutation:

The webhook also support inline mutation when your secret needs to be replaced somewhere inside a string.

Set the annotation `vault.security.banzaicloud.io/inline-mutation` to `true` and:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: aws-key-secret
data:
  config.yaml: >
foo: bar
secret: ${{vault:secret/data/mysecret#supersecret}}
type: Opaque
```
This works also for ConfigMap resources when `configMapMutation` is enabled.
To enable inline mutation globally, set the env variable `INLINE_MUTATION: true` on the webhook.

You can specify the version of the injected Vault secret as well in the special reference, the format is: `vault:PATH#KEY_OR_TEMPLATE#VERSION`

Example:

```yaml
        env:
        - name: AWS_SECRET_ACCESS_KEY
          value: vault:secret/data/accounts/aws#AWS_SECRET_ACCESS_KEY#2
```

There is a special `vault:login` reference format to request a working Vault token into an environment variable to be later consumed by your application:

```yaml
        env:
        - name: VAULT_TOKEN
          value: vault:login
```

Values starting with `"vault:"` issue a `read` (HTTP GET) request towards the Vault API, this can be also used to request a [dynamic database username/password pair for MySQL](https://www.vaultproject.io/docs/secrets/databases/mysql-maria.html#usage):

***NOTE**: This feature takes advantage of secret caching since we need to access the `my-role` endpoint twice, but in the background, it is written only once in Vault:*

```yaml
    env:
    - name: MYSQL_USERNAME
      value: "vault:database/creds/my-role#username"
    - name: MYSQL_PASSWORD
      value: "vault:database/creds/my-role#password"
```

Values starting with `">>vault:"` issue a `write` (HTTP POST/PUT) request towards the Vault API, some secret engine APIs should be `written` instead of `reading from` like the [Password Generator for HashiCorp Vault](https://github.com/sethvargo/vault-secrets-gen):

```yaml
    env:
    - name: MY_SECRET_PASSWORD
      value: ">>vault:gen/password#value"
```

Or with [Transit Secret Engine](https://www.vaultproject.io/api-docs/secret/transit#decrypt-data) which is a fairly complex example since we are using templates when rendering the response and send data in the write request as well, the format is: `vault:PATH#KEY_OR_TEMPLATE#DATA`

Example: 

```yaml
    env:
    - name: MY_SECRET_PASSWORD
      value: ">>vault:transit/decrypt/mykey#${.plaintext | b64dec}#{"ciphertext":"vault:v1:/DupSiSbX/ATkGmKAmhqD0tvukByrx6gmps7dVI="}"
```

[Templating](https://golang.org/pkg/text/template/) is also supported on the secret sourced from Vault (in the key part, after the first `#`), in the very same fashion as in the Vault configuration and external configuration with all [the Sprig functions](http://masterminds.github.io/sprig/) (this is supported only for Pods right now):

```yaml
    env:
    - name: DOCKER_USERNAME
      value: "vault:secret/data/accounts/dockerhub#My username on DockerHub is: ${title .DOCKER_USERNAME}"
```

In this case, an init-container will be injected into the given Pod. This container copies the `vault-env` binary into an in-memory volume and mounts that Volume to every container which has an environment variable definition like that. It also changes the `command` of the container to run `vault-env` instead of your application directly. When `vault-env` starts up, it connects to Vault with the [Kubernetes Auth method](https://www.vaultproject.io/docs/auth/kubernetes.html) and checks the environment variables. The variables that have a reference to a value stored in Vault (`vault:secret/....`) are replaced with that value read from the Secret backend. After this, `vault-env` immediately executes (with `syscall.Exec()`) your process with the given arguments, replacing itself with that process (in non-daemon mode).

**With this solution none of your Secrets stored in Vault will ever land in Kubernetes Secrets, thus in etcd.**

`vault-env` was designed to work in Kubernetes in the first place, but nothing stops you to use it outside Kubernetes as well. It can be configured with the standard Vault client's [environment variables](https://www.vaultproject.io/docs/commands/#environment-variables) (because there is a standard Go Vault client underneath).

Currently, the Kubernetes Service Account-based Vault authentication mechanism is used by `vault-env`, so it requests a Vault token based on the Service Account of the container it is injected into. 

- [GCP](https://www.vaultproject.io/docs/auth/gcp) and general [OIDC/JWT](https://www.vaultproject.io/docs/auth/gcp) authentication methods are supported as well, see the [example manifest](https://github.com/banzaicloud/bank-vaults/blob/master/deploy/test-deployment-gcp.yaml).
- Kubernetes [Projected Service Account Tokens](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#service-account-token-volume-projection) work too, as shown in [this example](https://github.com/banzaicloud/bank-vaults/blob/master/hack/oidc-pod.yaml).


Kubernetes 1.12 introduced a feature called [APIServer dry-run](https://kubernetes.io/blog/2019/01/14/apiserver-dry-run-and-kubectl-diff/) which became beta as of 1.13. This feature requires some changes in webhooks with side effects. Vault mutating admission webhook is `dry-run aware`.


## Common Annotations

### PodSpec, Secret, ConfigMap and CRD annotations:
|Annotation    |default     |Explanation |
|--------------|------------|------------|
`vault.security.banzaicloud.io/vault-addr`|`"https://vault:8200"`|Same as VAULT_ADDR|
`vault.security.banzaicloud.io/vault-role`|`""`|The Vault role for Vault agent to use, for Pods it is the name of the ServiceAccount if not specified|
`vault.security.banzaicloud.io/vault-path`|`"kubernetes"`|The mount path of the auth method|
`vault.security.banzaicloud.io/vault-skip-verify`|`"false"`|Same as VAULT_SKIP_VERIFY|
`vault.security.banzaicloud.io/vault-tls-secret`|`""`|Name of the Kubernetes Secret holding the CA certificate for Vault|
`vault.security.banzaicloud.io/vault-ignore-missing-secrets`|`"false"`|When enabled will only log warnings when Vault secrets are missing|
`vault.security.banzaicloud.io/vault-env-passthrough`|`""`|Comma separated list of `VAULT_*` related environment variables to pass through to `vault-env` to the main process. E.g.`VAULT_ADDR,VAULT_ROLE`.|
`vault.security.banzaicloud.io/vault-env-daemon`|`"false"`|Run `vault-env` as a daemon instead of replacing itself with the main process|
`vault.security.banzaicloud.io/mutate-configmap`|`"false"`|Mutate the annotated ConfigMap as well (only Secrets and Pods are mutated by default)|
`vault.security.banzaicloud.io/enable-json-log`|`"false"`|Log in JSON format in `vault-env`|
`vault.security.banzaicloud.io/mutate`|`""`|Defines the mutation of the given resource, possible values: `"skip"` which prevents it.|
`vault.security.banzaicloud.io/vault-env-from-path`|`""`|Comma-delimited list of vault paths to pull in all secrets as environment variables|
`vault.security.banzaicloud.io/inline-mutation`|`"false"`|Enables inline mutation of secrets by using `${{vault:secret#field}}` inside a string|

## Deploying the webhook

### Helm chart

There is a Helm chart available to deploy the [Vault Secrets Webhook](https://github.com/banzaicloud/bank-vaults/tree/master/charts/vault-secrets-webhook). Note that:

- The user you use for deploying the chart to the k8s cluster needs cluster-admin privileges.
- The Helm chart of the vault-secrets-webhook contains the templates of the required permissions as well.
- The deployed RBAC objects contain the necessary permissions fo running the webhook.

Deploying with Helm 3:

```bash
helm repo add banzaicloud-stable https://kubernetes-charts.banzaicloud.com
kubectl create namespace vault-infra
kubectl label namespace vault-infra name=vault-infra
helm upgrade --namespace vault-infra --install vault-secrets-webhook banzaicloud-stable/vault-secrets-webhook
```

For further details follow the webhook's Helm chart [repository](https://github.com/banzaicloud/bank-vaults/tree/master/charts/vault-secrets-webhook).

## Example

Write a secret into Vault:

```bash
vault kv put secret/valami/aws AWS_SECRET_ACCESS_KEY=s3cr3t
```

This deployment will be mutated by the webhook since it has at least one environment variable having a value which is a reference to a path in Vault:

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
          value: vault:secret/data/valami/aws#AWS_SECRET_ACCESS_KEY
```

## Daemon mode

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

# Create a Vault instance with MySQL storage and a configured dynamic database secerts backend
kubectl apply -f operator/deploy/rbac.yaml
kubectl apply -f operator/deploy/cr-mysql-ha.yaml

# Deploy the example application requesting dynamic database credentials from the above Vault instance
kubectl apply -f deploy/test-dynamic-env-vars.yaml
kubectl logs -f deployment/hello-secrets
```

## Getting secret data from Vault and replace it in Kubernetes Secret (and/or ConfigMap)

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
