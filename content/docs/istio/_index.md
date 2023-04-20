---
title: Running the Bank-Vaults secret webhook alongside Istio
shorttitle: Istio and Bank-Vaults
weight: 680
---

Both the `vault-operator` and the `vault-secrets-webhook` can work on Istio enabled clusters quite well.

We support the following three scenarios:

- [Scenario 1: Vault runs outside an Istio mesh]({{< relref "/docs/bank-vaults/istio/vault-outside-the-mesh.md" >}}), whereas the namespace where the application runs and the webhook injects secrets has Istio sidecar injection enabled
- [Scenario 2]({{< relref "/docs/bank-vaults/istio/vault-inside-the-mesh.md" >}}): The namespace where Vault is running has Istio sidecar injection enabled
- [Scenario 3: Both namespaces have Istio sidecar injection enabled]({{< relref "/docs/bank-vaults/istio/vault-and-app-inside-the-mesh.md" >}})

## Prerequisites

### Install the Banzai Cloud [Istio operator](https://github.com/banzaicloud/istio-operator) with the [Backyards CLI](https://banzaicloud.com/docs/backyards/cli/)

1. First of all, you need to install the [Backyards CLI](https://github.com/banzaicloud/backyards-cli) on your cluster:

    {{< include-headless "download-backyards.md" >}}

1. Install the [Istio operator](https://github.com/banzaicloud/istio-operator) using Backyards.
    You need only the Istio operator, but you can experiment with the Backyards UI/CLI and the large collection of automated Istio features provided by Backyards like observability, traffic routing, canary, circuit breakers, and so on - check out this [long list of features](https://banzaicloud.com/docs/backyards/features/).
    We provide sample commands to configure Istio using Backyards and also using kubectl.

    ```bash
    backyards install
    ? Install istio-operator (recommended). Press enter to accept Yes
    ? Install canary-operator (recommended). Press enter to accept No
    ? Install and run demo application (optional). Press enter to skip No
    ```

1. Make sure you have [mTLS](https://istio.io/docs/tasks/security/authentication/authn-policy/#globally-enabling-istio-mutual-tls) enabled in the Istio mesh through the operator with the following command:

    Enable mTLS if it is not set to `STRICT`:

    - With `kubectl`:

        ```bash
        kubectl patch istio -n istio-system mesh --type=json -p='[{"op": "replace", "path": "/spec/meshPolicy/mtlsMode", "value":STRICT}]'
        ```

    - With `backyards`:

        ```bash
        ❯ backyards mtls require mesh
        INFO[0000] switched global mTLS to STRICT successfully
        ```

    After this, we can check that mesh is configured with `mTLS` turned on which applies to all applications in the cluster in Istio-enabled namespaces. You can change this if you would like to use another policy.

    - With `kubectl`:

        ```bash
        $ kubectl get meshpolicy default -o yaml
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

    - With `backyards`:

        ```bash
        $ backyards mtls get mesh
        mTLS rule for /mesh

        Policy    Targets  MtlsMode  
        /default  []       STRICT
        ```

Now your cluster is properly running on Istio with mTLS enabled globally.

### Install the Bank-Vaults components

1. You are recommended to create a separate namespace for [Bank-Vaults](https://banzaicloud.com/docs/bank-vaults/overview/) called `vault-system`. You can enable Istio sidecar injection here as well, but Kubernetes won't be able to call back the webhook properly since mTLS is enabled (and Kubernetes is outside of the Istio mesh). To overcome this, apply a `PERMISSIVE` Istio authentication policy to the `vault-secrets-webhook` Service itself, so Kubernetes can call it back without Istio mutual TLS authentication.

    ```bash
    kubectl create namespace vault-system
    kubectl label namespace vault-system name=vault-system istio-injection=enabled
    ```

    - With `kubectl`:

        ```bash
        $ kubectl apply -f - <<EOF
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

    - With `backyards`:

        ```bash
        $ backyards mtls allow vault-system/vault-secrets-webhook
        INFO[0001] policy peers for vault-system/vault-secrets-webhook set successfully

        mTLS rule for vault-system/vault-secrets-webhook

        Policy                                    Targets                  MtlsMode
        vault-system/vault-secrets-webhook-rw6mc  [vault-secrets-webhook]  PERMISSIVE
        ```

1. Now you can install the operator and the webhook to the prepared namespace:

    ```bash
    helm repo add banzaicloud-stable https://kubernetes-charts.banzaicloud.com
    helm upgrade --install vault-secrets-webhook banzaicloud-stable/vault-secrets-webhook --namespace vault-system
    helm upgrade --install vault-operator banzaicloud-stable/vault-operator --namespace vault-system
    ```

Soon the webhook and the operator become up and running. Check that the `istio-proxy` got injected into all Pods in `vault-system`.

Proceed to the description of your scenario:

- [Scenario 1: Vault runs outside an Istio mesh]({{< relref "/docs/bank-vaults/istio/vault-outside-the-mesh.md" >}}), whereas the namespace where the application runs and the webhook injects secrets has Istio sidecar injection enabled
- [Scenario 2]({{< relref "/docs/bank-vaults/istio/vault-inside-the-mesh.md" >}}): The namespace where Vault is running has Istio sidecar injection enabled
- [Scenario 3: Both namespaces have Istio sidecar injection enabled]({{< relref "/docs/bank-vaults/istio/vault-and-app-inside-the-mesh.md" >}})
