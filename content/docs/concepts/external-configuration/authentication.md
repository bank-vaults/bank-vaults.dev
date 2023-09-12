---
title: Authentication
weight: 300
aliases:
- /docs/external-configuration/authentication/
---

You can configure [Auth Methods in Vault](https://developer.hashicorp.com/vault/docs/auth).

Currently the following auth methods are supported:

- [AppRole](#auth-approle)
- [AWS](#auth-aws)
- [Azure](#auth-azure)
- [GCP](#auth-gcp)
- [GitHub](#auth-github)
- [JWT](#auth-jwt)
- [Kubernetes](#auth-kubernetes)
- [LDAP](#auth-ldap)

## AppRole auth method {#auth-approle}

Allow machines/apps to authenticate with Vault-defined roles. For details,
see the [official Vault documentation](https://developer.hashicorp.com/vault/docs/auth/approle).

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

## AWS auth method {#auth-aws}

Creating roles in Vault which can be used for
[AWS IAM based authentication](https://developer.hashicorp.com/vault/docs/auth/aws).

```yaml
auth:
  - type: aws
    # Make the auth provider visible in the web ui
    # See https://developer.hashicorp.com/vault/api-docs/system/auth#config for more
    # information.
    options:
      listing_visibility: "unauth"
    config:
      access_key: VKIAJBRHKH6EVTTNXDHA
      secret_key: vCtSM8ZUEQ3mOFVlYPBQkf2sO6F/W7a5TVzrl3Oj
      iam_server_id_header_value: vault-dev.example.com # consider setting this to the Vault server's DNS name
    crossaccountrole:
    # Add cross account number and role to assume in the cross account
    # https://developer.hashicorp.com/vault/api-docs/auth/aws#create-sts-role
    - sts_account: 12345671234
      sts_role: arn:aws:iam::12345671234:role/crossaccountrole
    roles:
    # Add roles for AWS instances or principals
    # See https://developer.hashicorp.com/vault/api-docs/auth/aws#create-role
    - name: dev-role-iam
      bound_iam_principal_arn: arn:aws:iam::123456789012:role/dev-vault
      policies: allow_secrets
      period: 1h
    - name: cross-account-role
      bound_iam_principal_arn: arn:aws:iam::12345671234:role/crossaccountrole
      policies: allow_secrets
      period: 1h
```

## Azure auth method {#auth-azure}

The Azure auth method allows authentication against Vault using
[Azure Active Directory credentials](https://developer.hashicorp.com/vault/docs/auth/azure) for more information.

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
    # See https://developer.hashicorp.com/vault/api-docs/auth/azure#create-role
      - name: dev-mi
        policies: allow_secrets
        bound_subscription_ids:
          - "00000000-0000-0000-0000-000000000000"
        bound_service_principal_ids:
          - "00000000-0000-0000-0000-000000000000"
```

## GCP auth method {#auth-gcp}

Create roles in Vault which can be used for
[GCP IAM based authentication](https://developer.hashicorp.com/vault/docs/auth/gcp).

```yaml
auth:
  - type: gcp
    # Make the auth provider visible in the web ui
    # See https://developer.hashicorp.com/vault/api-docs/system/auth#config for more
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
    # See https://developer.hashicorp.com/vault/api-docs/auth/gcp#create-role
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

## GitHub auth method {#auth-github}

Create team mappings in Vault which can be used later on for the [GitHub authentication](https://developer.hashicorp.com/vault/docs/auth/github#configuration).

```yaml
auth:
  - type: github
    # Make the auth provider visible in the web ui
    # See https://developer.hashicorp.com/vault/api-docs/system/auth#config for more
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

## JWT auth method {#auth-jwt}

Create roles in Vault which can be used for [JWT-based authentication](https://developer.hashicorp.com/vault/docs/auth/jwt).

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

## Kubernetes auth method {#auth-kubernetes}

Use the [Kubernetes auth method](https://developer.hashicorp.com/vault/docs/auth/kubernetes) to authenticate with Vault
using a Kubernetes Service Account Token.

```yaml
auth:
  - type: kubernetes
    # If you want to configure with specific kubernetes service account instead of default service account
    # https://developer.hashicorp.com/vault/docs/auth/kubernetes
    # config:
    #   token_reviewer_jwt: eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9....
    #   kubernetes_ca_cert: |
    #     -----BEGIN CERTIFICATE-----
    #     ...
    #     -----END CERTIFICATE-----
    #   kubernetes_host: https://192.168.64.42:8443
    # Allows creating roles in Vault which can be used later on for the Kubernetes based
    # authentication.
    #  See https://developer.hashicorp.com/vault/docs/auth/kubernetes#creating-a-role for
    # more information.
    roles:
      # Allow every pod in the default namespace to use the secret kv store
      - name: default
        bound_service_account_names: default
        bound_service_account_namespaces: default
        policies: allow_secrets
        ttl: 1h
```

## LDAP auth method {#auth-ldap}

Create group mappings in Vault which can be used for
[LDAP based authentication](https://developer.hashicorp.com/vault/docs/auth/ldap#configuration).

- To start an LDAP test server, run: **docker run -it --rm -p 389:389 -e LDAP_TLS=false --name ldap osixia/openldap**
- To start an LDAP admin server, run: **docker run -it --rm -p 6443:443 --link ldap:ldap -e PHPLDAPADMIN_LDAP_HOSTS=ldap -e PHPLDAPADMIN_LDAP_CLIENT_TLS=false osixia/phpldapadmin**

```yaml
auth:
  - type: ldap
    description: LDAP directory auth.
    # add mount options
    # See https://developer.hashicorp.com/vault/api-docs/system/auth#config for more
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
