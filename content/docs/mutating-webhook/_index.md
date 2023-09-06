---
title: Secret injection webhook
weight: 300
github_project_repo: "https://github.com/bank-vaults/vault-secrets-webhook"
cascade:
    github_project_repo: "https://github.com/bank-vaults/vault-secrets-webhook"
---

## How the webhook works - overview

Kubernetes secrets are the standard way in which applications consume secrets and credentials on Kubernetes. Any secret that is securely stored in Vault and then unsealed for consumption eventually ends up as a Kubernetes secret. However, despite their name, Kubernetes secrets are not secure, since they are only base64 encoded.

The secret injection webhook of Bank-Vaults is a mutating webhook that bypasses the Kubernetes secrets mechanism and injects the secrets retrieved from Vault directly into the Pods. Specifically, the mutating admission webhook injects (in a very non-intrusive way) an executable into containers of Deployments and StatefulSets. This executable can request secrets from Vault through special environment variable definitions.

![Kubernetes API requests](/img/vault-mutating-webhook-revisited.gif)

An important and unique aspect of the webhook is that it is a *daemonless* solution (although if you need it, you can [deploy the webhook in daemon mode]({{< relref "/docs/mutating-webhook/deploy.md#daemon-mode" >}}) as well).

## Why is this more secure than using Kubernetes secrets or any other custom sidecar container?

Our solution is particularly lightweight and uses only existing Kubernetes constructs like annotations and environment variables. No confidential data ever persists on the disk or in etcd - not even temporarily. All secrets are stored in memory, and are only visible to the process that requested them. Additionally, there is no persistent connection with Vault, and any Vault token used to read environment variables is flushed from memory before the application starts, in order to minimize attack surface.

If you want to make this solution even more robust, you can disable *kubectl exec*-ing in running containers. If you do so, no one will be able to hijack injected environment variables from a process.

{{< include-headless "mutating-webhook-config-examples-basic.md"  >}}

For further examples and use cases, see [Configuration examples and scenarios]({{< relref "/docs/mutating-webhook/configuration.md" >}}).
