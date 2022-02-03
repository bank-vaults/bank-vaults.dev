---
title: Audit devices
weight: 200
---

You can configure [Audit Devices in Vault](https://www.vaultproject.io/docs/audit/) (File, Syslog, Socket).

```yaml
audit:
  - type: file
    description: "File based audit logging device"
    options:
      file_path: /tmp/vault.log
```
