---
title: Startup secrets
weight: 700
aliases:
- /docs/external-configuration/startup-secrets/
---

Allows writing some secrets to Vault (useful for development purposes). For details,
see the [Key-Value secrets engine](https://developer.hashicorp.com/vault/docs/secrets/kv).

```yaml
startupSecrets:
  - type: kv
    path: secret/data/accounts/aws
    data:
      data:
        AWS_ACCESS_KEY_ID: secretId
        AWS_SECRET_ACCESS_KEY: s3cr3t
```
