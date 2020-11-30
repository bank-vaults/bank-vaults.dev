---
title: Operator
weight: 200
---

The Vault operator builds on Bank-Vaults features such as:

- external, API based configuration (secret engines, auth methods, policies) to automatically re/configure a Vault cluster
- automatic unsealing (AWS, GCE, Azure, Alibaba, Kubernetes Secrets (for dev purposes), Oracle)
- TLS support

The operator flow is the following:

![operator](images/vaultoperator.png)

The source code can be found in the [operator](https://github.com/banzaicloud/bank-vaults/tree/master/operator) directory.

The operator requires the following [cloud permissions](/docs/bank-vaults/cloud-permissions/).

{{< include-headless "deploy-operator-local.md" "bank-vaults" >}}

## HA setup with Raft

In a production environment you want to run Vault as a cluster. The following CR creates a 3-node Vault instance that uses the Raft storage backend:

1. Install the Bank-Vaults operator:

    ```bash
    helm repo add banzaicloud-stable https://kubernetes-charts.banzaicloud.com
    helm upgrade --install vault-operator banzaicloud-stable/vault-operator
    ```

1. Create a Vault instance using the `cr-raft.yaml` custom resource. This will create a Kubernetes `CustomResource` called `vault` that uses the Raft backend:

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/banzaicloud/bank-vaults/master/operator/deploy/rbac.yaml
    kubectl apply -f https://raw.githubusercontent.com/banzaicloud/bank-vaults/master/operator/deploy/cr-raft.yaml
    ```

{{< warning >}}
Backing up the storage backend to prevent data loss, is not handled by the Vault operator. We recommend using [Velero](../backup/) for backups.
{{< /warning >}}

## Pod anti-affinity

If you want to setup pod anti-affinity, you can set `podAntiAffinity` vault with a topologyKey value.
For example, you can use `failure-domain.beta.kubernetes.io/zone` to force K8S deploy vault on multi AZ.

## Delete a resource created by the operator

If you manually delete a resource that the Bank-Vaults operator has created (for example, the Ingress resource), the operator automatically recreates it every 30 seconds. If it doesn't, then something went wrong, or the operator is not running. In this case, check the logs of the operator.
