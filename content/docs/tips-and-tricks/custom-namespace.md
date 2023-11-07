---
title: Deploy vault into a custom namespace
linktitle: Custom namespace
---

To deploy Vault into a custom namespace (not into `default`), you have to:

1. Ensure that you have required permissions:

    ```bash
    export NAMESPACE="<your-custom-namespace>"
    cat <<EOF > kustomization.yaml | kubectl kustomize | kubectl apply -f -
    apiVersion: kustomize.config.k8s.io/v1beta1
    kind: Kustomization
    resources:
    - https://github.com/bank-vaults/vault-operator/deploy/rbac
    transformers:
    - |-
      apiVersion: builtin
      kind: NamespaceTransformer
      metadata:
        name: vault-namespace-transform
        namespace: $NAMESPACE
      setRoleBindingSubjects: defaultOnly
    EOF
    ```

1. Use the custom namespace in the following fields in the Vault CR:

    - [unsealConfig.kubernetes.secretNamespace](https://github.com/bank-vaults/vault-operator/blob/v{{< param "latest_operator_version" >}}/deploy/examples/cr.yaml#L116)
    - [config.api_addr](https://github.com/bank-vaults/vault-operator/blob/v{{< param "latest_operator_version" >}}/deploy/examples/cr-raft.yaml#L144)
    - [auth.roles.bound_service_account_namespaces](https://github.com/bank-vaults/vault-operator/blob/v{{< param "latest_operator_version" >}}/deploy/examples/cr-raft.yaml#L177)
    - [secrets.configuration.config.issuing_certificates and crl_distribution_points](https://github.com/bank-vaults/vault-operator/blob/v{{< param "latest_operator_version" >}}/deploy/examples/cr.yaml#L194-L195)
    - [secrets.configuration.root/generate.common_name](https://github.com/bank-vaults/vault-operator/blob/v{{< param "latest_operator_version" >}}/deploy/examples/cr.yaml#L198)

    If not using CRDs, you have to use the custom namespace in the following fields of the Vault Helm chart:

    - [vault.externalConfig.auth.roles.bound_service_account_namespaces](https://github.com/bank-vaults/vault-helm-chart/blob/v{{< param "latest_version" >}}/vault/values.yaml#L179)
    - [unsealer.args](https://github.com/bank-vaults/vault-helm-chart/blob/v{{< param "latest_version" >}}/vault/values.yaml#L255)

1. Deploy the Vault CustomResource to the custom namespace. For example:

    ```bash
    kubectl apply --namespace <your-custom-namespace> -f <your-customized-vault-cr>
    ```
