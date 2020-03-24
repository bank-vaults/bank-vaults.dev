---
title: Running the Bank-Vaults secret webhook alongside Istio
shorttitle: Istio and Bank-Vaults
weight: 680
---

Both the `vault-operator` and the `vault-secrets-webhook` can work on Istio enabled clusters quite well.

We support the following three scenarios:

- Scenario 1: Vault runs outside an Istio mesh, whereas the namespace where the application runs and the webhook injects secrets has Istio sidecar injection enabled
- Scenario 2: The namespace where Vault is running has Istio sidecar injection enabled
- Scenario 3: Both namespaces have Istio sidecar injection enabled

## Prerequisites

### Install the Banzai Cloud [Istio operator](https://github.com/banzaicloud/istio-operator) with the [Backyards CLI](https://banzaicloud.com/docs/backyards/cli/)

1. First of all, you need to install the [Backyards CLI](https://github.com/banzaicloud/backyards-cli) on your cluster:

    ```bash
    curl https://getbackyards.sh | sh
    ```

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

## Scenario 1: Vault runs outside, the application inside the mesh {#scenario1}

<p align="center"><img src="/img/blog/istio-vault/istio_vault1.png" ></p>

In this scenario, Vault runs outside an Istio mesh, whereas the namespace where the application runs and the webhook injects secrets has Istio sidecar injection enabled.

First, [install Vault outside the mesh](#install-vault-outside-mesh), then [install an application within the mesh](#install-application-inside-mesh).

### Install Vault outside the mesh {#install-vault-outside-mesh}

1. Provision a Vault instance with the Bank-Vaults operator in a separate namespace:

    ```bash
    kubectl create namespace vault
    ```

1. Apply the [RBAC](rbac.yaml) and [CR](cr-istio.yaml) files to the cluster to create a Vault instance in the `vault` namespace with the operator:

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

### Install the application inside a mesh {#install-application-inside-mesh}

In this scenario Vault is running outside the Istio mesh (as we have installed it in the [previous steps](#install-vault-outside-mesh)) and our demo application runs within the Istio mesh. To install the demo application inside the mesh, complete the following steps:

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

1. Install the application [manifest](app.yaml) to the cluster:

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

## Scenario 2: Running Vault inside the mesh {#scenario2}

<p align="center"><img src="/img/blog/istio-vault/istio_vault2.png" ></p>

To run Vault inside the mesh, complete the following steps. Note that these instructions assume that you have [Scenario 1](#scenario1) up and running, and modifying it to run Vault inside the mesh.

1. Turn off Istio in the `app` namespace by removing the `istio-injection` label:

    - With `kubectl`:

        ```bash
        kubectl label namespace app istio-injection-
        kubectl label namespace vault istio-injection=enabled
        ```

    - With `backyards`:

        ```bash
        backyards sidecar-proxy auto-inject off app
        backyards sidecar-proxy auto-inject on vault
        ```

1. Delete the Vault pods in the `vault` namespace, so they will get recreated with the `istio-proxy` sidecar:

    ```bash
    kubectl delete pods --all -n vault
    ```

1. Check that they both come back with an extra container (4/4 and 2/2 now):

    ```bash
    $ kubectl get pods -n vault
    NAME                                READY   STATUS    RESTARTS   AGE
    vault-0                             4/4     Running   0          1m
    vault-configurer-6d9b98c856-l4flc   2/2     Running   0          1m
    ```

1. Delete the application pods in the `app` namespace, so they will get recreated without the `istio-proxy` sidecar:

    ```bash
    kubectl delete pods --all -n app
    ```

The app pod got recreated with only the `app` container (1/1) and Vault access still works:

```bash
$ kubectl get pods -n app
NAME                  READY   STATUS    RESTARTS   AGE
app-5df5686c4-4n6r7   1/1     Running   0          71s

$ kubectl logs -f -n app deployment/app
time="2020-02-18T14:41:20Z" level=info msg="Received new Vault token"
time="2020-02-18T14:41:20Z" level=info msg="Initial Vault token arrived"
s3cr3t
going to sleep...
```

## Scenario 3: both Vault and the app are running inside the mesh

<p align="center"><img src="/img/blog/istio-vault/istio_vault3.png" ></p>

In this scenario, both Vault and the app are running inside the mesh. You can configure this scenario right after completing the [Prerequisites](#prerequisites).

1. Enable sidecar auto-injection for both namespaces:

    - With `kubectl`:

        ```bash
        kubectl label namespace app   istio-injection=enabled
        kubectl label namespace vault istio-injection=enabled
        ```

    - With `backyards`:

        ```bash
        backyards sidecar-proxy auto-inject on app
        backyards sidecar-proxy auto-inject on vault
        ```

1. Delete all pods so they are getting injected with the proxy:

    ```bash
    kubectl delete pods --all -n app
    kubectl delete pods --all -n vault
    ```

1. Check the logs in the app container. It should sill show success:

    ```bash
    $ kubectl logs -f -n app deployment/app
    time="2020-02-18T15:04:03Z" level=info msg="Initial Vault token arrived"
    time="2020-02-18T15:04:03Z" level=info msg="Renewed Vault Token"
    s3cr3t
    going to sleep...
    ```
