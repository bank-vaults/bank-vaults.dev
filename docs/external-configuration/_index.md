---
title: External configuration for Vault
shorttitle: External Vault configuration
weight: 30
---

In addition to the [standard Vault configuration](https://www.vaultproject.io/docs/configuration/index.html), the operator and CLI can continuously configure Vault using an external YAML/JSON configuration.
<!-- FIXME Explain how to use this feature and why is it good. CI/CD/gitops for vault? -->
<!-- FIXME This page is way too long, consider splitting it into smaller pages -->

The following sections describe the configuration sections you can use.

## Audit devices

You can configure [Audit Devices in Vault](https://www.vaultproject.io/docs/audit/) (File, Syslog, Socket).

```yaml
audit:
  - type: file
    description: "File based audit logging device"
    options:
      file_path: /tmp/vault.log
```

## Create policies in Vault {#policies}

You can create policies in Vault, and later use these policies in roles for the [Kubernetes-based authentication](#authentication). For details, see [Policies in the official Vault documentation](https://www.vaultproject.io/docs/concepts/policies.html).

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

## Authentication {#authentication}

You can configure [Auth Methods in Vault](https://www.vaultproject.io/docs/auth/index.html).

Currently the following auth methods are supported:

- [AppRole](#auth-approle)
- [AWS](#auth-aws)
- [Azure](#auth-azure)
- [GCP](#auth-gcp)
- [GitHub](#auth-github)
- [JWT](#auth-jwt)
- [Kubernetes](#auth-kubernetes)
- [LDAP](#auth-ldap)

### AppRole auth method {#auth-approle}

Allow machines/apps to authenticate with Vault-defined roles. For details, see the [official Vault documentation](https://www.vaultproject.io/docs/auth/approle.html).

```yaml
auth:
  - type: approle
    roles:
    - name: default
      policies: allow_secrets
      secret_id_ttl: 10m
      token_num_uses: 10
      token_ttl: 20m
      token_max_ttl: 30m
      secret_id_num_uses: 40
```

### AWS auth method {#auth-aws}

Creating roles in Vault which can be used for [AWS IAM based authentication](https://www.vaultproject.io/docs/auth/aws.html).

```yaml
auth:
  - type: aws
    # Make the auth provider visible in the web ui
    # See https://www.vaultproject.io/api/system/auth.html#config for more
    # information.
    options:
      listing_visibility: "unauth"
    config:
      access_key: VKIAJBRHKH6EVTTNXDHA
      secret_key: vCtSM8ZUEQ3mOFVlYPBQkf2sO6F/W7a5TVzrl3Oj
      iam_server_id_header_value: vault-dev.example.com # consider setting this to the Vault server's DNS name
    crossaccountrole:
    # Add cross account number and role to assume in the cross account
    # https://www.vaultproject.io/api/auth/aws/index.html#create-sts-role
    - sts_account: 12345671234
      sts_role: arn:aws:iam::12345671234:role/crossaccountrole
    roles:
    # Add roles for AWS instances or principals
    # See https://www.vaultproject.io/api/auth/aws/index.html#create-role
    - name: dev-role-iam
      bound_iam_principal_arn: arn:aws:iam::123456789012:role/dev-vault
      policies: allow_secrets
      period: 1h
    - name: cross-account-role
      bound_iam_principal_arn: arn:aws:iam::12345671234:role/crossaccountrole
      policies: allow_secrets
      period: 1h
```

### Azure auth method {#auth-azure}

The Azure auth method allows authentication against Vault using [Azure Active Directory credentials](https://www.vaultproject.io/docs/auth/azure.html for more information).

```yaml
auth:
  - type: azure
    config:
      tenant_id: 00000000-0000-0000-0000-000000000000
      resource: https://vault-dev.example.com
      client_id: 00000000-0000-0000-0000-000000000000
      client_secret: 00000000-0000-0000-0000-000000000000
    roles:
    # Add roles for azure identities
    # See https://www.vaultproject.io/api/auth/azure/index.html#create-role
      - name: dev-mi
        policies: allow_secrets
        bound_subscription_ids: 
          - "00000000-0000-0000-0000-000000000000"
        bound_service_principal_ids: 
          - "00000000-0000-0000-0000-000000000000"
```

### GCP auth method {#auth-gcp}

Create roles in Vault which can be used for [GCP IAM based authentication](https://www.vaultproject.io/docs/auth/gcp.html).

```yaml
auth:
  - type: gcp
    # Make the auth provider visible in the web ui
    # See https://www.vaultproject.io/api/system/auth.html#config for more
    # information.
    options:
      listing_visibility: "unauth"
    config:
      # Credentials context is service account's key. Can download when you create a key for service account. 
      # No need to manually create it. Just paste the json context as multiline yaml.
      credentials: -|
        {
          "type": "service_account",
          "project_id": "PROJECT_ID",
          "private_key_id": "KEY_ID",
          "private_key": "-----BEGIN PRIVATE KEY-----.....-----END PRIVATE KEY-----\n",
          "client_email": "SERVICE_ACCOUNT@PROJECT_ID.iam.gserviceaccount.com",
          "client_id": "CLIENT_ID",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
          "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/SERVICE_ACCOUNT%40PROJECT_ID.iam.gserviceaccount.com"
        }
    roles:
    # Add roles for gcp service account
    # See https://www.vaultproject.io/api/auth/gcp/index.html#create-role
    - name: user-role
      type: iam
      project_id: PROJECT_ID
      policies: "readonly_secrets"
      bound_service_accounts: "USER_SERVICE_ACCOUNT@PROJECT_ID.iam.gserviceaccount.com"
    - name: admin-role
      type: iam
      project_id: PROJECT_ID
      policies: "allow_secrets"
      bound_service_accounts: "ADMIN_SERVICE_ACCOUNT@PROJECT_ID.iam.gserviceaccount.com"
```

### GitHub auth method {#auth-github}

Create team mappings in Vault which can be used later on for the [GitHub authentication](https://www.vaultproject.io/docs/auth/github.html#configuration).

```yaml
auth:
  - type: github
    # Make the auth provider visible in the web ui
    # See https://www.vaultproject.io/api/system/auth.html#config for more
    # information.
    options:
      listing_visibility: "unauth"
    config:
      organization: banzaicloud
    map:
      # Map the banzaicloud GitHub team on to the dev policy in Vault
      teams:
        dev: dev
      # Map my username (bonifaido) to the root policy in Vault
      users:
        bonifaido: allow_secrets
```

### JWT auth method {#auth-jwt}

Create roles in Vault which can be used for [JWT-based authentication](https://www.vaultproject.io/docs/auth/jwt.html).

```yaml
auth:
  - type: jwt
    path: jwt
    config:
      oidc_discovery_url: https://myco.auth0.com/
    roles:
    - name: role1
      bound_audiences:
        - https://vault.plugin.auth.jwt.test
      user_claim: https://vault/user
      groups_claim: https://vault/groups
      policies: allow_secrets
      ttl: 1h
```

### Kubernetes auth method {#auth-kubernetes}

Use the [Kubernetes auth method](https://www.vaultproject.io/docs/auth/kubernetes.html) to authenticate with Vault using a Kubernetes Service Account Token.

```yaml
auth:
  - type: kubernetes
    # If you want to configure with specific kubernetes service account instead of default service account
    # https://www.vaultproject.io/docs/auth/kubernetes.html
    # config:
    #   token_reviewer_jwt: eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9....
    #   kubernetes_ca_cert: |
    #     -----BEGIN CERTIFICATE-----
    #     ...
    #     -----END CERTIFICATE-----
    #   kubernetes_host: https://192.168.64.42:8443
    # Allows creating roles in Vault which can be used later on for the Kubernetes based
    # authentication.
    #  See https://www.vaultproject.io/docs/auth/kubernetes.html#creating-a-role for
    # more information.
    roles:
      # Allow every pod in the default namespace to use the secret kv store
      - name: default
        bound_service_account_names: default
        bound_service_account_namespaces: default
        policies: allow_secrets
        ttl: 1h
```

### LDAP auth method {#auth-ldap}

Create group mappings in Vault which can be used for [LDAP based authentication](https://www.vaultproject.io/docs/auth/ldap.html#configuration).

- To start an LDAP test server, run: **docker run -it --rm -p 389:389 -e LDAP_TLS=false --name ldap osixia/openldap**
- To start an LDAP admin server, run: **docker run -it --rm -p 6443:443 --link ldap:ldap -e PHPLDAPADMIN_LDAP_HOSTS=ldap -e PHPLDAPADMIN_LDAP_CLIENT_TLS=false osixia/phpldapadmin**

```yaml
auth:
  - type: ldap
    description: LDAP directory auth.
    # add mount options
    # See https://www.vaultproject.io/api/system/auth.html#config for more
    # information.
    options:
      listing_visibility: "unauth"
    config:
      url: ldap://localhost
      binddn: "cn=admin,dc=example,dc=org"
      bindpass: "admin"
      userattr: uid
      userdn: "ou=users,dc=example,dc=org"
      groupdn: "ou=groups,dc=example,dc=org"
    groups:
      # Map the banzaicloud dev team on GitHub to the dev policy in Vault
      developers:
        policies: allow_secrets
    # Map myself to the allow_secrets policy in Vault
    users:
      bonifaido:
        groups: developers
        policies: allow_secrets
```

## Environment variables

Add environment variables. See the [database](#database) section for usage. Further information:

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

## Identity Groups

<!-- FIXME Does this section refer to https://www.vaultproject.io/docs/secrets/identity#identity-groups and if yes, should it be moved under the secrets engine section? -->

NOTE: Only external groups are supported at the moment through the use of group-aliases. For supported authentication backends (for example JWT, which automatically matches those aliases to groups returned by the backend) the configuration files for the groups and group-aliases need to be parsed after the authentication backend has been mounted. Ideally they should be in the same file to avoid of errors.

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

## Register a new plugin

To register a new plugin in [Vault's plugin catalog](https://www.vaultproject.io/api/system/plugins-catalog.html), set the **plugin_directory** option in the Vault server configuration to the directory where the plugin binary is located. Also, for some plugins readOnlyRootFilesystem Pod Security Policy should be disabled to allow RPC communication between plugin and Vault server via Unix socket. For details, see the [Hashicorp Go plugin documentation](https://github.com/hashicorp/go-plugin/blob/master/docs/internals.md).

```yaml
plugins:
  - plugin_name: ethereum-plugin
    command: ethereum-vault-plugin --ca-cert=/vault/tls/client/ca.crt --client-cert=/vault/tls/server/server.crt --client-key=/vault/tls/server/server.key
    sha256: 62fb461a8743f2a0af31d998074b58bb1a589ec1d28da3a2a5e8e5820d2c6e0a
    type: secret
```

## Secrets engines

You can configure [Secrets Engines in Vault](https://www.vaultproject.io/docs/secrets/index.html). The Key-Value, Database, and SSH values are tested, but the configuration is free form, so probably others work as well.

### AWS

The [AWS secrets engine](https://www.vaultproject.io/docs/secrets/aws/index.html) generates AWS access credentials dynamically based on IAM policies.

```yaml
secrets:
  - type: aws
    path: aws
    description: AWS Secret Backend
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

### Database {#database}

This plugin stores database credentials dynamically based on configured roles for the [MySQL/MariaDB database](https://www.vaultproject.io/docs/secrets/databases/mysql-maria.html).

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

### Key-Values

This plugin stores arbitrary secrets within the configured [physical storage for Vault](https://www.vaultproject.io/docs/secrets/kv/index.html).

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

### Non-default plugin path

Mounts a non-default plugin's path.

```yaml
  - path: ethereum-gateway
    type: plugin
    plugin_name: ethereum-plugin
    description: Immutability's Ethereum Wallet
```

### PKI

The [PKI secrets engine](https://www.vaultproject.io/docs/secrets/pki/index.html) generates X.509 certificates.

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

### RabbitMQ

The [RabbitMQ secrets engine](https://www.vaultproject.io/docs/secrets/rabbitmq/index.html) generates user credentials dynamically based on configured permissions and virtual hosts.

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

### SSH

Create a named Vault role for [signing SSH client keys](https://www.vaultproject.io/docs/secrets/ssh/signed-ssh-certificates.html#client-key-signing).

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
```

## Startup secrets

Allows writing some secrets to Vault (useful for development purposes). For details, see the [Key-Value secrets engine](https://www.vaultproject.io/docs/secrets/kv/index.html).

```yaml
startupSecrets:
  - type: kv
    path: secret/data/accounts/aws
    data:
      data:
        AWS_ACCESS_KEY_ID: secretId
        AWS_SECRET_ACCESS_KEY: s3cr3t
```
