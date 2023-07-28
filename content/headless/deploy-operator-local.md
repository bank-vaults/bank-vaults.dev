---
---
## Deploy a local Vault operator {#deploy-operator}

This is the simplest scenario: you install the Vault operator on a simple cluster. The following commands install a single-node Vault instance that stores unseal and root tokens in Kubernetes secrets.

1. Install the Bank-Vaults operator:

    ```bash
    helm repo add banzaicloud-stable https://kubernetes-charts.banzaicloud.com
    helm upgrade --install vault-operator oci://ghcr.io/bank-vaults/helm-charts/vault-operator
    ```

    Expected output:

    ```bash
    Release "vault-operator" does not exist. Installing it now.
    Pulled: ghcr.io/bank-vaults/helm-charts/vault-operator:1.20.0
    Digest: sha256:46045be1c3b215f0c734908bb1d4022dc91eae48d2285382bb71d63f72c737d1
    NAME: vault-operator
    LAST DEPLOYED: Thu Jul 27 11:22:55 2023
    NAMESPACE: default
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    ```

1. Create a Vault instance using the Vault custom resources. This will create a Kubernetes `CustomResource` called `vault` and a PersistentVolumeClaim for it:

    {{< include-headless "install-operator-rbac.md" >}}

    {{< include-headless "install-operator-cr.md" >}}

1. Wait a few seconds, then check the operator and the vault pods:

    ```bash
    kubectl get pods
    ```

    Expected output:

    ```bash
    NAME                                                        READY     STATUS    RESTARTS   AGE
    vault-0                                                     3/3       Running   0          10s
    vault-configurer-6c545cb6b4-dmvb5                           1/1       Running   0          10s
    vault-operator-788559bdc5-kgqkg                             1/1       Running   0          23s
    ```

1. Configure your Vault client to access the Vault instance running in the *vault-0* pod.

    1. Port-forward into the pod:

        ```bash
        kubectl port-forward vault-0 8200 &
        ```

    1. Set the address of the Vault instance.

        ```bash
        export VAULT_ADDR=https://127.0.0.1:8200
        ```

    1. Import the CA certificate of the Vault instance by running the following commands (otherwise, you'll get *x509: certificate signed by unknown authority* errors):

        ```bash
        kubectl get secret vault-tls -o jsonpath="{.data.ca\.crt}" | base64 --decode > $PWD/vault-ca.crt
        export VAULT_CACERT=$PWD/vault-ca.crt
        ```

        Alternatively, you can instruct the Vault client to skip verifying the certificate of Vault by running: `export VAULT_SKIP_VERIFY=true`

    1. If you already have the [Vault CLI installed](https://developer.hashicorp.com/vault/downloads), check that you can access the Vault:

        ```bash
        vault status
        ```

        Expected output:

        ```bash
        Key             Value
        ---             -----
        Seal Type       shamir
        Initialized     true
        Sealed          false
        Total Shares    5
        Threshold       3
        Version         1.5.4
        Cluster Name    vault-cluster-27ecd0e6
        Cluster ID      ed5492f3-7ef3-c600-aef3-bd77897fd1e7
        HA Enabled      false
        ```

    1. To authenticate to Vault, you can access its root token by running:

        ```bash
        export VAULT_TOKEN=$(kubectl get secrets vault-unseal-keys -o jsonpath={.data.vault-root} | base64 --decode)
        ```

        > Note: Using the root token is recommended only in test environments. In production environment, create dedicated, time-limited tokens.

    1. Now you can interact with Vault. For example, add a secret by running `vault kv put secret/demosecret/aws AWS_SECRET_ACCESS_KEY=s3cr3t`
        If you want to access the Vault web interface, open *https://127.0.0.1:8200* in your browser using the root token (to reveal the token, run `echo $VAULT_TOKEN`).

For other configuration examples of the Vault CustomResource, see the YAML files in the [deploy/examples](https://github.com/bank-vaults/vault-operator/tree/main/deploy/examples) and [test/deploy](https://github.com/bank-vaults/vault-operator/tree/main/test/deploy) directories of the vault-operator repository. After you are done experimenting with Bank-Vaults and you want to delete the operator, you can delete the related CRs:

```bash
kubectl kustomize https://github.com/bank-vaults/vault-operator/deploy/rbac | kubectl delete -f -
kubectl delete -f https://raw.githubusercontent.com/bank-vaults/vault-operator/v{{< param "latest_version" >}}/deploy/examples/cr-raft.yaml
```
