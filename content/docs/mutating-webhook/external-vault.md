---
title: Running the webhook and Vault on different clusters
linktitle: External Vault
weight: 600
---

This section describes how to configure the webhook and Vault when the webhook runs on a different cluster from Vault, or if Vault runs outside Kubernetes.

Let's suppose you have two different K8S clusters:

- `cluster1` contains `vault-operator`
- `cluster2` contains `vault-secrets-webhook`

Basically, you have to grant `cluster2` access to the Vault running on `cluster1`. To achieve this, complete the following steps.

1. Extract the *cluster.certificate-authority-data* and the *cluster.server* fields from your `cluster2` kubeconfig file. You will need them in the `externalConfig` section of the `cluster1` configuration. For example:

    ```bash
    kubectl config view -o yaml --minify=true --raw=true
    ```

1. Decode the certificate from the *cluster.certificate-authority-data* field, for example::

    ```bash
    grep 'certificate-authority-data' $HOME/.kube/config | awk '{print $2}' | base64 --decode
    ```

1. On `cluster2`, create a `vault` ServiceAccount and the `vault-auth-delegator` ClusterRoleBinding:

    ```bash
    kubectl apply -f https://github.com/bank-vaults/raw/main/operator/deploy/rbac.yaml
    ```

    You can use the `vault` ServiceAccount token as a `token_reviewer_jwt` in the auth configuration. To retrieve the token, run the following command:

    ```bash
    kubectl get secret $(kubectl get sa vault -o jsonpath='{.secrets[0].name}') -o jsonpath='{.data.token}' | base64 --decode
    ```

1. In the `vault.banzaicloud.com` custom resource (for example, in this [sample CR](https://github.com/bank-vaults/vault-operator/blob/main/deploy/examples/cr.yaml)) of `cluster1`, define an `externalConfig` section. Fill the values of the `kubernetes_ca_cert`, `kubernetes_host`, and `token_reviewer_jwt` using the data collected in the previous steps.

    ```yaml
      externalConfig:
        policies:
          - name: allow_secrets
            rules: path "secret/*" {
              capabilities = ["create", "read", "update", "delete", "list"]
              }
        auth:
          - type: kubernetes
            config:
              token_reviewer_jwt: <token-for-cluster2-service-account>
              kubernetes_ca_cert: |
                -----BEGIN CERTIFICATE-----
                <certificate-from-certificate-authority-data-on-cluster2>
                -----END CERTIFICATE-----
              kubernetes_host: <cluster.server-field-on-cluster2>
            roles:
              # Allow every pod in the default namespace to use the secret kv store
              - name: default
                bound_service_account_names: ["default", "vault-secrets-webhook"]
                bound_service_account_namespaces: ["default", "vswh"]
                policies: allow_secrets
                ttl: 1h
    ```

1. In a production environment, it is highly recommended to specify TLS config for your Vault ingress.

    ```yaml
      # Request an Ingress controller with the default configuration
      ingress:
        # Specify Ingress object annotations here, if TLS is enabled (which is by default)
        # the operator will add NGINX, Traefik and HAProxy Ingress compatible annotations
        # to support TLS backends
        annotations:
        # Override the default Ingress specification here
        # This follows the same format as the standard Kubernetes Ingress
        # See: https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.13/#ingressspec-v1beta1-extensions
        spec:
          tls:
          - hosts:
            - vault-dns-name
            secretName: vault-ingress-tls-secret
    ```

1. Deploy the `Vault` custom resource containing the `externalConfig` section to `cluster1`:

    ```bash
    kubectl apply -f your-proper-vault-cr.yaml
    ```

1. After Vault started in `cluster1`, you can use the `vault-secrets-webhook` in `cluster2` with the proper annotations. For example:

    ```yaml
    spec:
      replicas: 1
      selector:
        matchLabels:
          app.kubernetes.io/name: hello-secrets
      template:
        metadata:
          labels:
            app.kubernetes.io/name: hello-secrets
          annotations:
            vault.security.banzaicloud.io/vault-addr: "https://vault-dns-name:443"
            vault.security.banzaicloud.io/vault-role: "default"
            vault.security.banzaicloud.io/vault-skip-verify: "true"
            vault.security.banzaicloud.io/vault-path: "kubernetes"
    ```

--- 

Also you can use directly cloud identity to auth the mutating-webhook against the external vault.

1. Add your cloud auth method in your external vault [https://www.vaultproject.io/docs/auth/azure](https://www.vaultproject.io/docs/auth/azure)

2. Configure your `vault-secrets-webhook` to use the good method. For example:
```yaml
env:
  VAULT_ADDR: https://external-vault.example.com
  VAULT_AUTH_METHOD: azure
  VAULT_PATH: azure
  VAULT_ROLE: default
```
For `VAULT_AUTH_METHOD` env var, these types: **"kubernetes", "aws-ec2", "gcp-gce", "gcp-iam", "jwt", "azure"** are supported.
