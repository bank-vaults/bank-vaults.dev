---
title: Environment variables
weight: 40
aliases:
- /docs/environment-variables/
---

You can add environment variables to the different containers of the Bank-Vaults pod using the following configuration options:

- `envsConfig`: Adds environment variables to all Bank-Vaults pods.
- `sidecarEnvsConfig`: Adds environment variables to Vault sidecar containers.
- `vaultEnvsConfig`: Adds environment variables to the Vault container.

For example:

```yaml
envsConfig:
  - name: ROOT_USERNAME
    valueFrom:
      secretKeyRef:
        name: mysql-login
        key: user
  - name: ROOT_PASSWORD
    valueFrom:
      secretKeyRef:
        name: mysql-login
        key: password
```

See the [database secret engine]({{< relref "/docs/concepts/external-configuration/secrets-engines.md#database" >}}) section for usage. Further information:

- [List of Kubernetes environment variables](https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/)
- [Using secrets as environment variables](https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-environment-variables)
