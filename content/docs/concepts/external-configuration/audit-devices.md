---
title: Audit devices
weight: 200
aliases:
- /docs/external-configuration/audit-devices/
---

You can configure [Audit Devices in Vault](https://developer.hashicorp.com/vault/docs/audit) (File, Syslog, Socket).

```yaml
audit:
  - type: file
    description: "File based audit logging device"
    options:
      file_path: /tmp/vault.log
```
