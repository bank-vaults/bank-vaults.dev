---
title: Scenario 1 - Vault runs outside, the application inside the mesh
shorttitle: Vault outside the mesh
weight: 100
---

In this scenario, Vault runs outside an Istio mesh, whereas the namespace where the application runs and the webhook injects secrets has Istio sidecar injection enabled.

<p align="center"><img src="/img/blog/istio-vault/istio_vault1.png" ></p>

First, complete the {{% xref "/docs/bank-vaults/istio/_index.md#prerequisites" %}}, then [install Vault outside the mesh](#install-vault-outside-mesh), and finally [install an application within the mesh](#install-application-inside-mesh).

## Install Vault outside the mesh {#install-vault-outside-mesh}

1. Provision a Vault instance with the Bank-Vaults operator in a separate namespace:

    ```bash
    kubectl create namespace vault
    ```

1. Apply the [RBAC](../rbac.yaml) and [CR](../cr-istio.yaml) files to the cluster to create a Vault instance in the `vault` namespace with the operator:

    ```bash
    kubectl apply -f rbac.yaml -f cr-istio.yaml
    ```

    ```bash
    $ kubectl get pods -n vault
    NAME                               READY   STATUS    RESTARTS   AGE
    vault-0                            3/3     Running   0          22h
    vault-configurer-6458cc4bf-6tpkz   1/1     Running   0          22h
    ```

    If you are writing your own Vault CR make sure that `istioEnabled: true` is configured, this influences port naming so the Vault service port protocols are detected by Istio correctly.

1. The `vault-secrets-webhook` can't inject Vault secrets into `initContainers` in an Istio-enabled namespace when the `STRICT` authentication policy is applied to the Vault service, because Istio needs a sidecar container to do mTLS properly, and in the phase when `initContainers` are running the Pod doesn't have a sidecar yet.
    If you wish to inject into `initContainers` as well, you need to apply a `PERMISSIVE` authentication policy in the `vault` namespace, since it has its own TLS certificate outside of Istio scope (so this is safe to do from networking security point of view).

    - With `kubectl`:

        ```bash
        $ kubectl apply -f - <<EOF
        apiVersion: authentication.istio.io/v1alpha1
        kind: Policy
        metadata:
          name: default
          namespace: vault
          labels:
            app: security
        spec:
          peers:
          - mtls:
              mode: PERMISSIVE
        EOF
        ```

    - With `backyards`:

        ```bash
        $ backyards mtls allow vault
        INFO[0001] policy peers for vault/ set successfully

        mTLS rule for vault/

        Policy         Targets  MtlsMode
        vault/default  []       PERMISSIVE
        ```

## Install the application inside a mesh {#install-application-inside-mesh}

In this scenario Vault is running outside the Istio mesh (as we have installed it in the [previous steps](#install-vault-outside-mesh) and our demo application runs within the Istio mesh. To install the demo application inside the mesh, complete the following steps:

1. Create a namespace first for the application and enable Istio sidecar injection:

    ```bash
    kubectl create namespace app
    ```

    - With `kubectl`:

        ```bash
        kubectl label namespace app istio-injection=enabled
        ```

    - With `backyards`:

        ```bash
        backyards sidecar-proxy auto-inject on app
        ```

1. Install the application [manifest](../app.yaml) to the cluster:

    ```bash
    kubectl apply -f app.yaml
    ```

1. Check that the application is up and running. It should have two containers, the `app` itself and the `istio-proxy`:

    ```bash
    $ kubectl get pods -n app
    NAME                  READY   STATUS    RESTARTS   AGE
    app-5df5686c4-sl6dz   2/2     Running   0          119s
    ```

    ```bash
    $ kubectl logs -f -n app deployment/app app
    time="2020-02-18T14:26:01Z" level=info msg="Received new Vault token"
    time="2020-02-18T14:26:01Z" level=info msg="Initial Vault token arrived"
    s3cr3t
    going to sleep...
    ```
