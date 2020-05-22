---
title: Running the webhook an external Vault in different K8S clusters
shortTitle: External Vault
weight: 600
---

You have two different K8S clusters (or simply and external Vault outside of Kubernetes).

- `cluster1` contains `vault-operator`
- `cluster2` contains `vault-secrets-webhook`

You have a cluster with running `vault-operator` (`cluster1`), and you have to grant access to `Vault` from the other K8S cluster which contains `vault-secrets-webhook` (`cluster2`).

1. In your `vaults.vault.banzaicloud.com` under `operator/deploy/cr.yaml` custom resource you have to define proper `externalConfig` containing the `cluster2` config.

    from your (`cluster2`) kubeconfig file:
    You can get K8S cert and host:

    ```bash
    kubectl config view -o yaml --minify=true --raw=true
    ```

    you need to decode the cert before passing it in your `externalConfig`:

    ```bash
    grep 'certificate-authority-data' $HOME/.kube/config | awk '{print $2}' | base64 --decode
    ```

1. on `cluster2`, create a `vault` ServiceAccount and the `vault-auth-delegator` ClusterRoleBinding:

    ```bash
    kubectl apply -f operator/deployment/rbac.yaml
    ```

    You can use vault the ServiceSccount token as a `token_reviewer_jwt` in the auth configuration:

    ```bash
    kubectl get secret $(kubectl get sa vault -o jsonpath='{.secrets[0].name}') -o jsonpath='{.data.token}' | base64 --decode
    ```

1. Authentication against Vault is based on [Kubernetes Service Accounts](https://www.vaultproject.io/docs/auth/kubernetes). Now you can use a proper `kubernetes_ca_cert`, `kubernetes_host` and `token_reviewer_jwt` in your (`cluster1`) CR yaml file (or configure Vault manually according to the official docs):

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
              token_reviewer_jwt: webhook.cluster.token.reviewer.token
              kubernetes_ca_cert: |
                -----BEGIN CERTIFICATE-----
                webhook.cluster.cert
                -----END CERTIFICATE-----
              kubernetes_host: https://webhook-cluster
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

1. Deploy `Vault` with the operator in your `cluster1`:

    ```bash
    kubectl apply -f your-proper-vault-cr.yaml
    ```

1. After Vault started in `cluster1` you can use `vault-secrets-webhook` in `cluster2` with proper annotations:

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
