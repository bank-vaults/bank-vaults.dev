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

## Inline mutation

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

In this case, an init-container will be injected into the given Pod. This container copies the `vault-env` binary into an in-memory volume and mounts that Volume to every container which has an environment variable definition like that. It also changes the `command` of the container to run `vault-env` instead of your application directly. When `vault-env` starts up, it connects to Vault with the [Kubernetes Auth method](https://www.vaultproject.io/docs/auth/kubernetes.html) and checks the environment variables. The variables that have a reference to a value stored in Vault (`vault:secret/....`) are replaced with that value read from the Secret backend. After this, `vault-env` immediately executes (with `syscall.Exec()`) your process with the given arguments, replacing itself with that process (in non-daemon mode).

**With this solution none of your Secrets stored in Vault will ever land in Kubernetes Secrets, thus in etcd.**

`vault-env` was designed to work in Kubernetes in the first place, but nothing stops you to use it outside Kubernetes as well. It can be configured with the standard Vault client's [environment variables](https://www.vaultproject.io/docs/commands/#environment-variables) (because there is a standard Go Vault client underneath).

Currently, the Kubernetes Service Account-based Vault authentication mechanism is used by `vault-env`, so it requests a Vault token based on the Service Account of the container it is injected into.

- [GCP](https://www.vaultproject.io/docs/auth/gcp) and general [OIDC/JWT](https://www.vaultproject.io/docs/auth/gcp) authentication methods are supported as well, see the [example manifest](https://github.com/banzaicloud/bank-vaults/blob/master/deploy/test-deployment-gcp.yaml).
- Kubernetes [Projected Service Account Tokens](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/#service-account-token-volume-projection) work too, as shown in [this example](https://github.com/banzaicloud/bank-vaults/blob/master/hack/oidc-pod.yaml).

Kubernetes 1.12 introduced a feature called [APIServer dry-run](https://kubernetes.io/blog/2019/01/14/apiserver-dry-run-and-kubectl-diff/) which became beta as of 1.13. This feature requires some changes in webhooks with side effects. Vault mutating admission webhook is `dry-run aware`.
