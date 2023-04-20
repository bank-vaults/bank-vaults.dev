---
title: Fully or partially purging unmanaged configuration in Vault
linktitle: Purge unmanaged configuration 
weight: 100
---

Bank-Vaults gives you a full control over Vault in a declarative style by removing any unmanaged configuration.

By enabling `purgeUnmanagedConfig` you keep Vault configuration up-to-date.
So if you added a policy using Bank-Vaults then removed it from the configuration,
Bank-Vaults will remove it from Vault too. In other words, if you enabled `purgeUnmanagedConfig`
then any changes not in Bank-Vaults configuration will be removed (including manual changes).

> Note:
> 
> This feature is `destructive`, so be carful when you enable it especially for the first time
> **because it could delete all data in your Vault.** We recommend you to test it a non-production environment first.

This feature is disabled by default and it needs to be enabled explicitly in your configuration.

## Mechanism

Bank-Vaults handles unmanaged configuration by simply comparing what in Bank-Vaults configuration (the desired state)
and what's already in Vault (the actual state), then it removes any differences that are not in Bank-Vaults
configuration.

## Fully purge unmanaged configuration

You can remove **all** unmanaged configuration by enabling the purge option as following:

```yaml
purgeUnmanagedConfig:
  enabled: true
```

## Partially purge unmanaged configuration

You can also enable the purge feature for some of the config by excluding any config that
you don't want to purge its unmanaged config.

It could be done by explicitly exclude the Vault configuration that you don't want to mange:

```yaml
purgeUnmanagedConfig:
  enabled: true
  exclude:
    secrets: true
```

This will remove any unmanaged or manual changes in Vault but it will leave `secrets` untouched.
So if you enabled a new secret engine manually (and it's not in Bank-Vaults configuration),
Bank-Vaults will not remove it.
