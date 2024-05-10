---
title: Using Vault Agent Templating in the mutating webhook
linktitle: Vault Agent Templating
weight: 50
---

With Bank-Vaults you can use [Vault Agent](https://developer.hashicorp.com/vault/docs/agent-and-proxy/agent) to handle secrets that expire, and supply them to applications that read their configurations from a file.

## When to use vault-agent

- You have an application or tool that requires to read its configuration from a file.
- You wish to have secrets that have a TTL and expire.
- You have no issues with running your application with a sidecar.

> Note: If you need to revoke tokens, or use additional secret backends, see {{% xref "/docs/mutating-webhook/consul-template.md" %}}.

## Workflow

- Your pod starts up, the webhook will inject one container into the pods lifecycle.
- The sidecar container is running Vault, using the [vault agent](https://developer.hashicorp.com/vault/docs/agent-and-proxy/agent) that accesses Vault using the configuration specified inside a configmap and writes a configuration file based on a pre configured template (written inside the same configmap) onto a temporary file system which your application can use.

## Prerequisites

This document assumes the following.

- You have a working Kubernetes cluster which has:

  - a working Vault installation
  - a working installation of the [mutating webhook]({{< relref "/docs/mutating-webhook/_index.md" >}}).

- You have a working knowledge of Kubernetes.
- You can apply Deployments or PodSpec's to the cluster.
- You can change the configuration of the [mutating webhook]({{< relref "/docs/mutating-webhook/configuration.md" >}}).

## Use Vault TTLs

If you wish to use Vault TTLs, you need a way to HUP your application on configuration file change. You can [configure the Vault Agent to execute a command](https://developer.hashicorp.com/vault/docs/agent-and-proxy/agent/template) when it writes a new configuration file using the `command` attribute. The following is a basic example which uses the Kubernetes authentication method.

{{< include-code "vault-agent-templating-example.yaml" "yaml" >}}

## Configuration

To configure the webhook, you can either:

- set some sane defaults in the [environment of the mutating webhook](#defaults), or
- configure it via annotations in your [PodSpec](#podspec).

### Enable vault agent in the webhook

For the webhook to detect that it will need to mutate or change a PodSpec, add the `vault.security.banzaicloud.io/vault-agent-configmap` annotation to the Deployment or PodSpec you want to mutate, otherwise it will be ignored for configuration with Vault Agent.

### Defaults via environment variables {#defaults}

| Variable                            | Default                                                         | Explanation                                                  |
|-------------------------------------|-----------------------------------------------------------------|--------------------------------------------------------------|
| VAULT_IMAGE                         | hashicorp/vault:latest                                          | The vault image to use for the sidecar container             |
| VAULT_IMAGE_PULL_POLICY             | IfNotPresent                                                    | The pull policy for the vault agent container                |
| VAULT_ADDR                          | <https://127.0.0.1:8200>                                        | Kubernetes service Vault endpoint URL                        |
| VAULT_TLS_SECRET                    | ""                                                              | Supply a secret with the vault TLS CA so TLS can be verified |
| VAULT_AGENT_SHARE_PROCESS_NAMESPACE | Kubernetes version <1.12 default off, 1.12 or higher default on | ShareProcessNamespace override                               |

### PodSpec annotations {#podspec}

| Annotation                                                        | Default                                           | Explanation                                                                             |
|-------------------------------------------------------------------|---------------------------------------------------|-----------------------------------------------------------------------------------------|
| vault.security.banzaicloud.io/vault-addr                          | Same as VAULT_ADDR above                          | ""                                                                                      |
| vault.security.banzaicloud.io/vault-tls-secret                    | Same as VAULT_TLS_SECRET above                    | ""                                                                                      |
| vault.security.banzaicloud.io/vault-agent-configmap               | ""                                                | A configmap name which holds the vault agent configuration                              |
| vault.security.banzaicloud.io/vault-agent-once                    | False                                             | Do not run vault-agent in daemon mode, useful for kubernetes jobs                       |
| vault.security.banzaicloud.io/vault-agent-share-process-namespace | Same as VAULT_AGENT_SHARE_PROCESS_NAMESPACE above | ""                                                                                      |
| vault.security.banzaicloud.io/vault-agent-cpu                     | 100m                                              | Specify the vault-agent container CPU resource limit                                    |
| vault.security.banzaicloud.io/vault-agent-memory                  | 128Mi                                             | Specify the vault-agent container memory resource limit                                 |
| vault.security.banzaicloud.io/vault-agent-cpu-request             | 100m                                              | Specify the vault-agent container CPU resource request                                  |
| vault.security.banzaicloud.io/vault-agent-cpu-limit               | 100m                                              | Specify the vault-agent container CPU resource limit (Overridden by vault-agent-cpu)    |
| vault.security.banzaicloud.io/vault-agent-memory-request          | 128Mi                                             | Specify the vault-agent container memory resource request                               |
| vault.security.banzaicloud.io/vault-agent-memory-limit            | 128Mi                                             | Specify the vault-agent container memory resource limit (Overridden by vault-agent-cpu) |
| vault.security.banzaicloud.io/vault-configfile-path               | /vault/secrets                                    | Mount path of Vault Agent rendered files                                                |
