---
title: Configuration examples and scenarios
shorttitle: Configure the webhook
weight: 50
---

The following examples show you how to configure the mutating webhook to best suit your environment.

{{< include-headless "mutating-webhook-config-examples-basic.md" "bank-vaults" >}}

## Inject secret into resources

The webhook can inject into any kind of resources, even into CRDs, for example:

```yaml
apiVersion: mysql.example.github.com/v1
kind: MySQLCluster
metadata:
  name: "my-cluster"
spec:
  caBundle: "vault:pki/cert/43138323834372136778363829719919055910246657114#ca"
```

## Inline mutation {#inline}

The webhook also supports inline mutation when your secret needs to be replaced somewhere inside a string.

Set the annotation `vault.security.banzaicloud.io/inline-mutation` to `true` and:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: aws-key-secret
data:
  config.yaml: >
foo: bar
secret: ${vault:secret/data/mysecret#supersecret}
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

## Define multiple inline-secrets in resources

You can also inject multiple secrets under the same key in a Secret/ConfigMap/Object. This means that you can use multiple Vault paths in a value, for example:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: sample-configmap
  annotations:
    vault.security.banzaicloud.io/vault-addr: "https://vault.default:8200"
    vault.security.banzaicloud.io/vault-role: "default"
    vault.security.banzaicloud.io/vault-tls-secret: vault-tls
    vault.security.banzaicloud.io/vault-path: "kubernetes"
    vault.security.banzaicloud.io/inline-mutation: "true"
data:
  aws-access-key-id: "vault:secret/data/accounts/aws#AWS_ACCESS_KEY_ID"
  aws-access-template: "vault:secret/data/accounts/aws#AWS key in base64: ${.AWS_ACCESS_KEY_ID | b64enc}"
  aws-access-inline: "AWS_ACCESS_KEY_ID: ${vault:secret/data/accounts/aws#AWS_ACCESS_KEY_ID} AWS_SECRET_ACCESS_KEY: ${vault:secret/data/accounts/aws#AWS_SECRET_ACCESS_KEY}"
```

This example also shows how a CA certificate (created by the operator) can be used with the `vault.security.banzaicloud.io/vault-tls-secret: vault-tls` annotation to validate the TLS connection in case of a non-Pod resource.

## Request a Vault token

There is a special `vault:login` reference format to request a working Vault token into an environment variable to be later consumed by your application:

```yaml
        env:
        - name: VAULT_TOKEN
          value: vault:login
```

## Read a value from Vault

Values starting with `"vault:"` issue a `read` (HTTP GET) request towards the Vault API, this can be also used to request a [dynamic database username/password pair for MySQL](https://www.vaultproject.io/docs/secrets/databases/mysql-maria.html#usage):

***NOTE**: This feature takes advantage of secret caching since we need to access the `my-role` endpoint twice, but in the background, it is written only once in Vault:*

```yaml
    env:
    - name: MYSQL_USERNAME
      value: "vault:database/creds/my-role#username"
    - name: MYSQL_PASSWORD
      value: "vault:database/creds/my-role#password"
    - name: REDIS_URI
      value: "redis://${vault:database/creds/my-role#username}:${vault:database/creds/my-role#password}@127.0.0.1:6739"
```

## Write a value into Vault

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

## Templating in values

[Templating](https://golang.org/pkg/text/template/) is also supported on the secret sourced from Vault (in the key part, after the first `#`), in the very same fashion as in the Vault configuration and external configuration with all [the Sprig functions](http://masterminds.github.io/sprig/) (this is supported only for Pods right now):

```yaml
    env:
    - name: DOCKER_USERNAME
      value: "vault:secret/data/accounts/dockerhub#My username on DockerHub is: ${title .DOCKER_USERNAME}"
```

In this case, an init-container will be injected into the given Pod. This container copies the `vault-env` binary into an in-memory volume and mounts that Volume to every container which has an environment variable definition like that. It also changes the `command` of the container to run `vault-env` instead of your application directly. When `vault-env` starts up, it connects to Vault to checks the environment variables. (By default, `vault-env` uses the [Kubernetes Auth method](https://www.vaultproject.io/docs/auth/kubernetes.html), but you can also [configure other authentication methods for the webhook](#webhook-auth).) The variables that have a reference to a value stored in Vault (`vault:secret/....`) are replaced with that value read from the Secret backend. After this, `vault-env` immediately executes (with `syscall.Exec()`) your process with the given arguments, replacing itself with that process (in non-daemon mode).

**With this solution none of your Secrets stored in Vault will ever land in Kubernetes Secrets, thus in etcd.**

`vault-env` was designed to work in Kubernetes in the first place, but nothing stops you to use it outside Kubernetes as well. It can be configured with the standard Vault client's [environment variables](https://www.vaultproject.io/docs/commands/#environment-variables) (because there is a standard Go Vault client underneath).

Currently, the Kubernetes Service Account-based Vault authentication mechanism is used by `vault-env`, so it requests a Vault token based on the Service Account of the container it is injected into.

- [GCP](https://www.vaultproject.io/docs/auth/gcp) and general [OIDC/JWT](https://www.vaultproject.io/docs/auth/gcp) authentication methods are supported as well, see the [example manifest](https://github.com/banzaicloud/bank-vaults/blob/master/deploy/test-deployment-gcp.yaml).
- Kubernetes [Projected Service Account Tokens](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#service-account-token-volume-projection) work too, as shown in [this example](https://github.com/banzaicloud/bank-vaults/blob/master/hack/oidc-pod.yaml).

Kubernetes 1.12 introduced a feature called [APIServer dry-run](https://kubernetes.io/blog/2019/01/14/apiserver-dry-run-and-kubectl-diff/) which became beta as of 1.13. This feature requires some changes in webhooks with side effects. Vault mutating admission webhook is `dry-run aware`.

## Mutate data from Vault and replace it in Kubernetes Secret

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

## Use charts without explicit container.command and container.args

The Webhook can determine the container's `ENTRYPOINT` and `CMD` with the help of image metadata queried from the image registry. This data is cached until the webhook Pod is restarted. If the registry is publicly accessible (without authentication) you don't need to do anything, but if the registry requires authentication the credentials have to be available in the Pod's `imagePullSecrets` section.

Some examples (apply `cr.yaml` from the operator samples first):

```bash
helm upgrade --install mysql stable/mysql \
  --set mysqlRootPassword=vault:secret/data/mysql#MYSQL_ROOT_PASSWORD \
  --set mysqlPassword=vault:secret/data/mysql#MYSQL_PASSWORD \
  --set "podAnnotations.vault\.security\.banzaicloud\.io/vault-addr"=https://vault:8200 \
  --set "podAnnotations.vault\.security\.banzaicloud\.io/vault-tls-secret"=vault-tls
```

## Registry access

You can also specify a default secret being used by the webhook for cases where a pod has no `imagePullSecrets` specified. To make this work you have to set the environment variables `DEFAULT_IMAGE_PULL_SECRET` and `DEFAULT_IMAGE_PULL_SECRET_NAMESPACE` when deploying the vault-secrets-webhook. Have a look at the values.yaml of the
[vault-secrets-webhook](https://github.com/banzaicloud/bank-vaults/blob/master/charts/vault-secrets-webhook/values.yaml) helm chart to see how this is done.

> Note:
> - If your EC2 nodes have the ECR instance role, the webhook can request an ECR access token through that role automatically, instead of an explicit `imagePullSecret`
> - If your workload is running on GCP nodes, the webhook automatically authenticates to GCR.

Future improvements:

- on Azure/Alibaba get a credential dynamically with the specific SDK (for AWS ECR and GCP GCR this is already done)

### Using a private image repository

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

## Mount all keys from Vault secret to env

This feature is very similar to Kubernetes' standard `envFrom:` [construct](https://kubernetes.io/docs/concepts/configuration/secret/#use-case-as-container-environment-variables), but instead of a Kubernetes Secret/ConfigMap, all its keys are mounted from a Vault secret using the webhook and vault-env.

You can set the Vault secret to mount using the `vault.security.banzaicloud.io/vault-env-from-path` annotation.

Compared to the original environment variable definition in the Pod `env` construct, the only difference is that you won't see the actual environment variables in the definition, because they are dynamic, and are based on the contents of the Vault secret's, just like `envFrom:`.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-secrets
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: hello-secrets
  template:
    metadata:
      labels:
        app.kubernetes.io/name: hello-secrets
      annotations:
        vault.security.banzaicloud.io/vault-addr: "https://vault:8200"
        vault.security.banzaicloud.io/vault-tls-secret: vault-tls
        vault.security.banzaicloud.io/vault-env-from-path: "secret/data/accounts/aws"
    spec:
      initContainers:
      - name: init-ubuntu
        image: ubuntu
        command: ["sh", "-c", "echo AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID && echo initContainers ready"]
      containers:
      - name: alpine
        image: alpine
        command: ["sh", "-c", "echo AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY && echo going to sleep... && sleep 10000"]
```

## Authenticate the webhook to Vault {#webhook-auth}

By default, the webhook uses Kubernetes [ServiceAccount-based authentication](https://www.vaultproject.io/docs/auth/kubernetes) in Vault. Use the `vault.security.banzaicloud.io/vault-auth-method` annotation to request different authentication types from the following supported types: **"kubernetes", "aws-ec2", "gcp-gce", "jwt"**. The following deployment - if running on a GCP instance - will automatically receive a signed-JWT token from the metadata server of the cloud provider, and use it to authenticate against Vault. The same goes for `vault-auth-method: "aws-ec2"`, when running on an EC2 node with the right instance-role.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vault-env-gcp-auth
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: vault-env-gcp-auth
  template:
    metadata:
      labels:
        app.kubernetes.io/name: vault-env-gcp-auth
      annotations:
        # These annotations enable Vault GCP GCE auth, see:
        # https://www.vaultproject.io/docs/auth/gcp#gce-login
        vault.security.banzaicloud.io/vault-addr: "https://vault:8200"
        vault.security.banzaicloud.io/vault-tls-secret: vault-tls
        vault.security.banzaicloud.io/vault-role: "my-role"
        vault.security.banzaicloud.io/vault-path: "gcp"
        vault.security.banzaicloud.io/vault-auth-method: "gcp-gce"
    spec:
      containers:
        - name: alpine
          image: alpine
          command:
            - "sh"
            - "-c"
            - "echo $MYSQL_PASSWORD && echo going to sleep... && sleep 10000"
          env:
            - name: MYSQL_PASSWORD
              value: vault:secret/data/mysql#MYSQL_PASSWORD
```
