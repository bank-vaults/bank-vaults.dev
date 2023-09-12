---
title: bank-vaults CLI tool
weight: 700
github_project_repo: "https://github.com/bank-vaults/bank-vaults"
cascade:
    github_project_repo: "https://github.com/bank-vaults/bank-vaults"
---

The `bank-vaults` CLI tool is to help automate the setup and management of HashiCorp Vault.

Features:

- Initializes Vault and stores the root token and unseal keys in one of the followings:
  - AWS KMS keyring (backed by S3)
  - Azure Key Vault
  - Google Cloud KMS keyring (backed by GCS)
  - Alibaba Cloud KMS (backed by OSS)
  - Kubernetes Secrets (should be used only for development purposes)
  - Dev Mode (useful for `vault server -dev` dev mode Vault servers)
  - Files (backed by files, should be used only for development purposes)
- Automatically unseals Vault with these keys
- {{< include-headless "external-config-intro.md" >}}
    - If the configuration is updated, Vault will be reconfigured.
    - The external configuration supports configuring Vault secret engines, plugins, auth methods, policies, and more.

    For details, see {{% xref "/docs/concepts/external-configuration/_index.md" %}}.

The `bank-vaults` CLI command needs certain [cloud permissions]({{< relref "/docs/cloud-permissions/_index.md" >}}) to function properly (init, unseal, configuration).
