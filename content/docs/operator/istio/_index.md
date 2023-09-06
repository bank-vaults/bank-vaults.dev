---
title: Running the Bank-Vaults secret webhook alongside Istio
linktitle: Istio and vault-operator
weight: 680
aliases:
- /docs/istio/
---

Both the `vault-operator` and the `vault-secrets-webhook` can work on Istio-enabled clusters.

We support the following three scenarios:

- [Scenario 1: Vault runs outside an Istio mesh]({{< relref "/docs/operator/istio/vault-outside-the-mesh.md" >}}), whereas the namespace where the application runs and the webhook injects secrets has Istio sidecar injection enabled
- [Scenario 2]({{< relref "/docs/operator/istio/vault-inside-the-mesh.md" >}}): The namespace where Vault is running has Istio sidecar injection enabled
- [Scenario 3: Both namespaces have Istio sidecar injection enabled]({{< relref "/docs/operator/istio/vault-and-app-inside-the-mesh.md" >}})

## Prerequisites

1. Install the [Istio operator](https://github.com/banzaicloud/istio-operator).
1. Make sure you have [mTLS](https://istio.io/docs/tasks/security/authentication/authn-policy/#globally-enabling-istio-mutual-tls) enabled in the Istio mesh through the operator with the following command:

    Enable mTLS if it is not set to `STRICT`:

    ```bash
    kubectl patch istio -n istio-system mesh --type=json -p='[{"op": "replace", "path": "/spec/meshPolicy/mtlsMode", "value":STRICT}]'
    ```

1. Check that mesh is configured with `mTLS` turned on which applies to all applications in the cluster in Istio-enabled namespaces. You can change this if you would like to use another policy.

    ```bash
    kubectl get meshpolicy default -o yaml
    ```

    Expected output:

    ```yaml
    apiVersion: authentication.istio.io/v1alpha1
    kind: MeshPolicy
    metadata:
      name: default
      labels:
        app: security
    spec:
      peers:
      - mtls: {}
    ```

Now your cluster is properly running on Istio with mTLS enabled globally.

## Install the Bank-Vaults components

1. You are recommended to create a separate namespace for Bank-Vaults called `vault-system`. You can enable Istio sidecar injection here as well, but Kubernetes won't be able to call back the webhook properly since mTLS is enabled (and Kubernetes is outside of the Istio mesh). To overcome this, apply a `PERMISSIVE` Istio authentication policy to the `vault-secrets-webhook` Service itself, so Kubernetes can call it back without Istio mutual TLS authentication.

    ```bash
    kubectl create namespace vault-system
    kubectl label namespace vault-system name=vault-system istio-injection=enabled
    ```

    ```bash
    kubectl apply -f - <<EOF
    apiVersion: authentication.istio.io/v1alpha1
    kind: Policy
    metadata:
      name: vault-secrets-webhook
      namespace: vault-system
      labels:
        app: security
    spec:
      targets:
      - name: vault-secrets-webhook
      peers:
      - mtls:
          mode: PERMISSIVE
    EOF
    ```

1. Now you can install the operator and the webhook to the prepared namespace:

    ```bash
    helm upgrade --install --wait vault-secrets-webhook oci://ghcr.io/bank-vaults/helm-charts/vault-secrets-webhook --namespace vault-system --create-namespace
    helm upgrade --install --wait vault-operator oci://ghcr.io/bank-vaults/helm-charts/vault-operator --namespace vault-system
    ```

Soon the webhook and the operator become up and running. Check that the `istio-proxy` got injected into all Pods in `vault-system`.

Proceed to the description of your scenario:

- [Scenario 1: Vault runs outside an Istio mesh]({{< relref "/docs/operator/istio/vault-outside-the-mesh.md" >}}), whereas the namespace where the application runs and the webhook injects secrets has Istio sidecar injection enabled
- [Scenario 2]({{< relref "/docs/operator/istio/vault-inside-the-mesh.md" >}}): The namespace where Vault is running has Istio sidecar injection enabled
- [Scenario 3: Both namespaces have Istio sidecar injection enabled]({{< relref "/docs/operator/istio/vault-and-app-inside-the-mesh.md" >}})
