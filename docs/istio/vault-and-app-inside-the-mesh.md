---
title: Scenario 3 - Both Vault and the app are running inside the mesh
shorttitle: Vault and app inside the mesh
weight: 300
---

In this scenario, both Vault and the app are running inside the mesh.

<p align="center"><img src="/img/blog/istio-vault/istio_vault3.png" ></p>

1. Complete the [Prerequisites]({{< relref "/docs/bank-vaults/istio/_index.md#prerequisites" >}}).
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
