---
title: Tips and tricks
weight: 1150
---

The following section lists some questions, problems, and tips that came up on the [Bank-Vaults Slack channel](https://pages.banzaicloud.com/invite-slack).

## Deploy the webhook from a private registry

If you are getting the **x509: certificate signed by unknown authority app=vault-secrets-webhook** error when the webhook is trying to download the manifest from a private image registry, you can:

- Build a docker image where the CA store of the OS layer of the image contains the CA certificate of the registry.
- Alternatively, you can disable certificate verification for the registry by using the **REGISTRY_SKIP_VERIFY="true"** environment variable in the deployment of the webhook.

## Login to the Vault web UI

To login to the Vault web UI,  you can use the root token, or any configured authentication backend.
