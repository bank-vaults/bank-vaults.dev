---
title: Startup secrets
weight: 700
---

Allows writing some secrets to Vault (useful for development purposes). For details,
see the [Key-Value secrets engine](https://www.vaultproject.io/docs/secrets/kv/index.html).

```yaml
startupSecrets:
  - type: kv
    path: secret/data/accounts/aws
    data:
      data:
        AWS_ACCESS_KEY_ID: secretId
        AWS_SECRET_ACCESS_KEY: s3cr3t
```
