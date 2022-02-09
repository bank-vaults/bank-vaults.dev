---
title: Policies
weight: 500
---

You can create policies in Vault, and later use these policies in roles for the
[Kubernetes-based authentication]({{< relref "/docs/bank-vaults/external-configuration/authentication.md" >}}). For details,
see [Policies in the official Vault documentation](https://www.vaultproject.io/docs/concepts/policies.html).

```yaml
policies:
  - name: allow_secrets
    rules: path "secret/*" {
             capabilities = ["create", "read", "update", "delete", "list"]
           }
  - name: readonly_secrets
    rules: path "secret/*" {
             capabilities = ["read", "list"]
           }
```
