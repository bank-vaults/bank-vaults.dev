---
title: Contributing guide
weight: 1200
---

Thanks for your interest in contributing to Bank-Vaults!

Here are a few general guidelines on contributing and reporting bugs that we ask you to review and follow.

Please note that all of your interactions in the project are subject to our [Code of Conduct]({{< relref "/docs/code-of-conduct.md" >}}). This
includes creation of issues or pull requests, commenting on issues or pull requests, and extends to all interactions in
any real-time space e.g., Slack, Discord, etc.

Submitting pull requests and code changes is not the only way to contribute:

- If you use Bank-Vaults in a production environment, add yourself to the [adopters list](https://github.com/bank-vaults/bank-vaults/blob/master/ADOPTERS.md).
- Help new users with issues they may encounter on the GitHub Issues pages of our repositories
- Participate in discussions in the [#bank-vaults community Slack channel](https://eti.cisco.com/slack) or in [GitHub Discussions](https://github.com/orgs/bank-vaults/discussions)
- Support the development of this project and [star our GitHub repos](https://github.com/bank-vaults)!
- Report bugs or request features in [GitHub repos](https://github.com/bank-vaults)
- Review and update the existing content of our [documentation](https://bank-vaults.dev) with up-to-date instructions and code samples

## Reporting issues

Before reporting a new issue, please ensure that the issue was not already reported or fixed by searching through our issue tracker.

When creating a new issue, please be sure to include a **title and clear description**, as much relevant information as
possible, and, if possible, a test case.

**If you discover a security bug, please do not report it through GitHub issues. Instead, please follow the steps in [Security procedures]({{< relref "/docs/security.md" >}}).**

## Sending pull requests

Before sending a new pull request, take a look at existing pull requests and issues to see if the proposed change or fix
has been discussed in the past, or if the change was already implemented but not yet released.

We expect new pull requests to include tests for any affected behavior, and, as we follow semantic versioning, we may
reserve breaking changes until the next major version release.

## Development environment

In your development environment you can use file mode for testing `bank-vaults` cli-tool:

```shell
vault server -config vault.hcl
```

**example vault.hcl:**

```shell
api_addr = "http://localhost:8200"

storage "file" {
  path = "/tmp/vault"
}

listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = true
}
```

Now you have a running vault server which is uninitialized and unsealed you can init and unseal it with `bank-vaults` cli-tool and unseal keys will be stored to a local file:

```shell
VAULT_ADDR=http://127.0.0.1:8200 bank-vaults unseal --init --mode file
```

The unseal keys and root token are stored your working directory:

```shell
vault-root
vault-unseal-0
vault-unseal-1
vault-unseal-2
vault-unseal-3
vault-unseal-4
```

## Operator

Developing the operator requires a *working Kubernetes cluster*, minikube and Docker for Mac Kubernetes will suffice.

The operator consists of two parts, the *bank-vaults sidecar* running inside a container and the *operator itself*.

You can fire up the operator on your machine, so you can debug it locally (yes you don't have to build a container from it), if your kube context points to the development cluster:

```bash
make operator-up
```

This installs all the necessary RBAC rules and other CRDs that you need to create a Vault instance. If you change the code of the operator you have to `CTRL + C` this `make` command and rerun it again.

Now it is time create a Vault instance for yourself, which you can work on:

```bash
kubectl apply -f operator/deploy/cr.yaml
```

If you change the *bank-vaults sidecar* code you have to build a new Docker image from it:

```bash
DOCKER_LATEST=1 make docker
```

There are at least four ways to distribute this image in your Kubernetes cluster, by default `IfNotPresent` image pull policy is used:

- If you are using Docker for Mac, you don't have to anything, the Kubernetes cluster and your host shares the same Docker daemon.
- If you are using Minikube with `--vm-driver=none` (you are probably using Linux) the same applies as for Docker for Mac
- If you are using Minikube with some real `vm-driver` you have to run `eval $(minikube docker-env)` before building the Docker image with the `make` command so you build it with the minikube Docker daemon and the image will be stored there
- Build and re-tag the image and push it to the Docker registry of your choice, don't forget to change the `bankVaultsImage` attribute in the the Vault Custom Resource YAML file (`cr.yaml` in this case).

Restart the containers using the `bank-vaults` image: Vault instances and the configurer.

## Webhook

This will deploy the webhook via the Helm chart, scale it to 0, start it locally and proxy it into the cluster (somehow similar to `operator-up` but a bit more complex).

You will need Helm and `kurun` [installed](https://github.com/banzaicloud/kurun#installation) to run this:

```bash
make webhook-up -j
```

Now you can try out with mutating a Deployment:

```bash
kubectl apply -f deploy/test-deployment.yaml
```
