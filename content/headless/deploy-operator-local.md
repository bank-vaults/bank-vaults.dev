---
---
## Deploy a local Vault operator {#deploy-operator}

This is the simplest scenario: you install the Vault operator on a simple cluster. The following commands install a single-node Vault instance that stores unseal and root tokens in Kubernetes secrets.

1. Install the Bank-Vaults operator:

    ```bash
    helm repo add banzaicloud-stable https://kubernetes-charts.banzaicloud.com
    helm upgrade --install vault-operator banzaicloud-stable/vault-operator
    ```

    Expected output:

    ```bash
    Release "vault-operator" does not exist. Installing it now.
    NAME: vault-operator
    LAST DEPLOYED: Fri Jul 14 14:41:18 2023
    NAMESPACE: default
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    ```

1. Create a Vault instance using the Vault custom resources. This will create a Kubernetes `CustomResource` called `vault` and a PersistentVolumeClaim for it:

    > Note: The following commands use a specific version of the CRs, because the current version is not yet working, as we are in the process of migrating the Bank-Vaults repositories.

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/banzaicloud/bank-vaults/v1.15.3/operator/deploy/rbac.yaml
    kubectl apply -f https://raw.githubusercontent.com/banzaicloud/bank-vaults/v1.15.3/operator/deploy/cr.yaml
    ```

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

For other configuration examples of the Vault CustomResource, see the YAML files in the [operator/deploy directory of the project](https://github.com/bank-vaults/bank-vaults/tree/master/operator/deploy) (we use these for testing). After you are done experimenting with Bank-Vaults and you want to delete the operator, you can delete the related CRs:

```bash
kubectl delete -f https://raw.githubusercontent.com/banzaicloud/bank-vaults/master/operator/deploy/rbac.yaml
kubectl delete -f https://raw.githubusercontent.com/banzaicloud/bank-vaults/master/operator/deploy/cr.yaml
```
