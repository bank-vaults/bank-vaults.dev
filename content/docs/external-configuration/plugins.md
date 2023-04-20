---
title: Plugins
weight: 400
---

To register a new plugin in [Vault's plugin catalog](https://www.vaultproject.io/api/system/plugins-catalog.html),
set the **plugin_directory** option in the Vault server configuration to the directory where the plugin binary
is located. Also, for some plugins readOnlyRootFilesystem Pod Security Policy should be disabled to allow RPC
communication between plugin and Vault server via Unix socket. For details,
see the [Hashicorp Go plugin documentation](https://github.com/hashicorp/go-plugin/blob/master/docs/internals.md).

```yaml
plugins:
  - plugin_name: ethereum-plugin
    command: ethereum-vault-plugin --ca-cert=/vault/tls/client/ca.crt --client-cert=/vault/tls/server/server.crt --client-key=/vault/tls/server/server.key
    sha256: 62fb461a8743f2a0af31d998074b58bb1a589ec1d28da3a2a5e8e5820d2c6e0a
    type: secret
```
