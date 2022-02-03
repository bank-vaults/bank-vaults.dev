---
title: Environment variables
weight: 40
---

Add environment variables. See the [database secret engine]({{< relref "/docs/bank-vaults/external-configuration/secrets-engines.md" >}}) section for usage. Further information:

- [List of Kubernetes environment variables](https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/)
- [Using secrets as environment variables](https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-environment-variables)

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
