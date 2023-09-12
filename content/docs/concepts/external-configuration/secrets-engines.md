---
title: Secrets engines
weight: 600
aliases:
- /docs/external-configuration/secrets-engines/
---

You can configure [Secrets Engines in Vault](https://developer.hashicorp.com/vault/docs/secrets).
The Key-Value, Database, and SSH values are tested, but the configuration is free form, so probably others work as well.

## AWS

The [AWS secrets engine](https://developer.hashicorp.com/vault/docs/secrets/aws) generates AWS access credentials
dynamically based on IAM policies.

```yaml
secrets:
  - type: aws
    path: aws
    description: AWS Secrets Engine
    configuration:
        config:
          - name: root
            access_key: "${env `AWS_ACCESS_KEY_ID`}"
            secret_key: "${env `AWS_SECRET_ACCESS_KEY`}"
            region: us-east-1
        roles:
          - credential_type: iam_user
            policy_arns: arn-of-policy
            name: my-aws-role
```

## Consul

The [Consul secrets engine](https://developer.hashicorp.com/vault/docs/secrets/consul) generates Consul ACL tokens dynamically based on policies created in Consul.

```yaml
secrets:
  - path: consul
    type: consul
    description: Consul secrets
    configuration:
      config:
        - name: "access"
          address: "consul-server:8500"
          token: "${env `CONSUL_GLOBAL_MANAGEMENT_TOKEN`}" # Example how to read environment variables
      roles:
        - name: "<application_name>-read-only-role"
          consul_policies: "<application_name>-read-only-policy"
        - name: "<application_name>-read-write-role"
          consul_policies: "<application_name>-read-write-policy"
```

## Database {#database}

This plugin stores database credentials dynamically based on configured roles for the
[MySQL/MariaDB database](https://developer.hashicorp.com/vault/docs/secrets/databases/mysql-maria).

```yaml
secrets:
  - type: database
    description: MySQL Database secret engine.
    configuration:
      config:
        - name: my-mysql
          plugin_name: "mysql-database-plugin"
          connection_url: "{{username}}:{{password}}@tcp(127.0.0.1:3306)/"
          allowed_roles: [pipeline]
          username: "${env `ROOT_USERNAME`}" # Example how to read environment variables
          password: "${env `ROOT_PASSWORD`}"
      roles:
        - name: pipeline
          db_name: my-mysql
          creation_statements: "GRANT ALL ON *.* TO '{{name}}'@'%' IDENTIFIED BY '{{password}}';"
          default_ttl: "10m"
          max_ttl: "24h"
```

## Identity Groups

Allows you to configure [identity groups](https://www.vaultproject.io/docs/secrets/identity#identity-groups).

> Note:
>
> Only external groups are supported at the moment through the use of group-aliases.
> For supported authentication backends (for example JWT, which automatically matches those aliases
> to groups returned by the backend) the configuration files for the groups and group-aliases
> need to be parsed after the authentication backend has been mounted. Ideally they should be in the same file
> to avoid of errors.

```yaml
groups:
  - name: admin
    policies:
      - admin
    metadata:
      admin: "true"
      priviliged: "true"
    type: external

group-aliases:
  - name: admin
    mountpath: jwt
    group: admin
```

## Key-Values

This plugin stores arbitrary secrets within the configured
[physical storage for Vault](https://developer.hashicorp.com/vault/docs/secrets/kv).

```yaml
secrets:
  - path: secret
    type: kv
    description: General secrets.
    options:
      version: 2
    configuration:
      config:
        - max_versions: 100
```

## Non-default plugin path

Mounts a non-default plugin's path.

```yaml
  - path: ethereum-gateway
    type: plugin
    plugin_name: ethereum-plugin
    description: Immutability's Ethereum Wallet
```

## PKI

The [PKI secrets engine](https://developer.hashicorp.com/vault/docs/secrets/pki) generates X.509 certificates.

```yaml
secrets:
  - type: pki
    description: Vault PKI Backend
    config:
      default_lease_ttl: 168h
      max_lease_ttl: 720h
    configuration:
      config:
      - name: urls
        issuing_certificates: https://vault.default:8200/v1/pki/ca
        crl_distribution_points: https://vault.default:8200/v1/pki/crl
      root/generate:
      - name: internal
        common_name: vault.default
      roles:
      - name: default
        allowed_domains: localhost,pod,svc,default
        allow_subdomains: true
        generate_lease: true
        ttl: 30m
```

## RabbitMQ

The [RabbitMQ secrets engine](https://developer.hashicorp.com/vault/docs/secrets/rabbitmq)
generates user credentials dynamically based on configured permissions and virtual hosts.

To start a RabbitMQ test server, run: **docker run -it --rm -p 15672:15672 rabbitmq:3.7-management-alpine**

```yaml
secrets:
  - type: rabbitmq
    description: local-rabbit
    configuration:
      config:
        - name: connection
          connection_uri: "http://localhost:15672"
          username: guest
          password: guest
      roles:
        - name: prod_role
          vhosts: '{"/web":{"write": "production_.*", "read": "production_.*"}}'
```

## SSH

Create a named Vault role for
[signing SSH client keys](https://developer.hashicorp.com/vault/docs/secrets/ssh/signed-ssh-certificates#client-key-signing).

```yaml
secrets:
  - type: ssh
    path: ssh-client-signer
    description: SSH Client Key Signing.
    configuration:
      config:
        - name: ca
          generate_signing_key: "true"
      roles:
        - name: my-role
          allow_user_certificates: "true"
          allowed_users: "*"
          key_type: "ca"
          default_user: "ubuntu"
          ttl: "24h"
          default_extensions:
            permit-pty: ""
            permit-port-forwarding: ""
            permit-agent-forwarding: ""
```
