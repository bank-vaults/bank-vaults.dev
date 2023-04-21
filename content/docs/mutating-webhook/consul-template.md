---
title: Using consul-template in the mutating webhook
linktitle: Consul template
weight: 100
---

With Bank-Vaults you can use [Consul Template](https://github.com/hashicorp/consul-template) as an addition to vault-env to handle secrets that expire, and supply them to applications that read their configurations from a file.

## When to use consul-template

- You have an application or tool that must read its configuration from a file.
- You wish to have secrets that have a TTL and expire.
- You do not wish to be limited on which vault secrets backend you use.
- You can also expire tokens/revoke tokens (to do this you need to have a ready/live probe that can send a HUP to consul-template when the current details fail).

## Workflow

The following shows the general workflow for using Consul Template:

1. Your pod starts up. The webhook injects an init container (running vault agent) and a sidecar container (running consul-template) into the pods lifecycle.
1. The [vault agent](https://www.vaultproject.io/docs/agent/) in the init container logs in to Vault and retrieves a Vault token based on the configured VAULT_ROLE and Kubernetes Service Account.
1. The consul-template running in the sidecar container logs in to Vault using the Vault token and writes a configuration file based on a pre-configured template in a configmap onto a temporary file system which your application can use.

## Prerequisites

This document assumes the following.

- You have a working Kubernetes cluster which has:

    - a working Vault installation
    - a working installation of the [mutating webhook]({{< relref "/docs/mutating-webhook/_index.md" >}}).

- You have a working knowledge of Kubernetes.
- You can apply Deployments or PodSpec's to the cluster.
- You can change the configuration of the [mutating webhook]({{< relref "/docs/mutating-webhook/configuration.md" >}}).

## Use Vault TTLs

If you wish to use Vault TTLs, you need a way to HUP your application on configuration file change. You can [configure the Consul Template to execute a command](https://github.com/hashicorp/consul-template#configuration-file-format) when it writes a new configuration file using the `command` attribute. The following is a basic example (adapted from [here](https://github.com/sethvargo/vault-kubernetes-workshop/blob/master/k8s/db-sidecar.yaml#L79-L100)).

{{< include-code "consul-template-example.yaml" "yaml" >}}

## Configuration

To configure the webhook, you can either:

- set some sane defaults in the [environment of the mutating webhook](#defaults), or
- configure it via annotations in your [PodSpec](#podspec).

### Enable Consul Template in the webhook

For the webhook to detect that it will need to mutate or change a PodSpec, add the `vault.security.banzaicloud.io/vault-ct-configmap` annotation to the Deployment or PodSpec you want to mutate, otherwise it will be ignored for configuration with Consul Template.

### Defaults via environment variables {#defaults}

|Variable      |default     |Explanation|
|--------------|------------|------------|
|VAULT_IMAGE   |vault:latest|the vault image to use for the init container|
|VAULT_ENV_IMAGE|banzaicloud/vault-env:latest| the vault-env image to use |
|VAULT_CT_IMAGE|hashicorp/consul-template:latest| the consul template image to use|
|VAULT_ADDR    |https://127.0.0.1:8200|Kubernetes service Vault endpoint URL|
|VAULT_SKIP_VERIFY|"false"|should vault agent and consul template skip verifying TLS|
|VAULT_TLS_SECRET|""|supply a secret with the vault TLS CA so TLS can be verified|
|VAULT_AGENT   |"true"|enable the vault agent|
|VAULT_CT_SHARE_PROCESS_NAMESPACE|Kubernetes version <1.12 default off, 1.12 or higher default on|ShareProcessNamespace override|as above|

### PodSpec annotations {#podspec}

|Annotation    |default     |Explanation|
|--------------|------------|------------|
vault.security.banzaicloud.io/vault-addr|Same as VAULT_ADDR above||
vault.security.banzaicloud.io/vault-role|default|The Vault role for Vault agent to use|
vault.security.banzaicloud.io/vault-path|auth/&lt;method type>|The mount path of the method|
vault.security.banzaicloud.io/vault-skip-verify|Same as VAULT_SKIP_VERIFY above||
vault.security.banzaicloud.io/vault-tls-secret|Same as VAULT_TLS_SECRET above||
vault.security.banzaicloud.io/vault-agent|Same as VAULT_AGENT above||
vault.security.banzaicloud.io/vault-ct-configmap|""|A configmap name which holds the consul template configuration|
vault.security.banzaicloud.io/vault-ct-image|""|Specify a custom image for consul template|
vault.security.banzaicloud.io/vault-ct-once|false|do not run consul-template in daemon mode, useful for kubernetes jobs|
vault.security.banzaicloud.io/vault-ct-pull-policy|IfNotPresent|the Pull policy for the consul template container|
vault.security.banzaicloud.io/vault-ct-share-process-namespace|Same as VAULT_CT_SHARE_PROCESS_NAMESPACE above|
vault.security.banzaicloud.io/vault-ct-cpu|"100m"|Specify the consul-template container CPU resource limit|
vault.security.banzaicloud.io/vault-ct-memory|"128Mi"|Specify the consul-template container memory resource limit|
vault.security.banzaicloud.io/vault-ignore-missing-secrets|"false"|When enabled will only log warnings when Vault secrets are missing|
vault.security.banzaicloud.io/vault-env-passthrough|""|Comma seprated list of `VAULT_*` related environment variables to pass through to main process. E.g.`VAULT_ADDR,VAULT_ROLE`.|
vault.security.banzaicloud.io/vault-ct-secrets-mount-path|"/vault/secret"|Mount path of Consul template rendered files|
