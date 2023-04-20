---
title: Scenario 2 - Running Vault inside the mesh
linktitle: Vault inside the mesh
weight: 200
---

To run Vault inside the mesh, complete the following steps.

<p align="center"><img src="/img/istio_vault2.png" ></p>

> Note: These instructions assume that you have [Scenario 1]({{< relref "/docs/istio/vault-outside-the-mesh.md" >}}) up and running, and modifying it to run Vault inside the mesh.

1. Turn off Istio in the `app` namespace by removing the `istio-injection` label:

    ```bash
    kubectl label namespace app istio-injection-
    kubectl label namespace vault istio-injection=enabled
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
