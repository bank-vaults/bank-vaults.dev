---
title: Policies
weight: 500
---

You can create policies in Vault, and later use these policies in roles for the
[Kubernetes-based authentication]({{< relref "/docs/external-configuration/authentication.md" >}}). For details,
see [Policies in the official Vault documentation](https://developer.hashicorp.com/vault/docs/concepts/policies).

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
