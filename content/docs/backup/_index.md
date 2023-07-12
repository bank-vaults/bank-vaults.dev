---
title: Backing up Vault
weight: 650
---

You can configure the vault-operator to create backups of the Vault cluster with [Velero](https://velero.io/).

## Prerequisites

- The [Velero CLI](https://velero.io/docs/v1.5/basic-install/#install-the-cli) must be installed on your computer.
- To create Persistent Volume (PV) snapshots, you need access to an object storage. The following example uses an Amazon S3 bucket called `bank-vaults-velero` in the Stockholm region.

## Install Velero

To configure the vault-operator to create backups of the Vault cluster, complete the following steps.

1. Install Velero on the target cluster with Helm.

    1. Add the Velero Helm repository:

        ```bash
        helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
        ```

    1. Create a namespace for Velero:

        ```bash
        kubectl create namespace velero
        ```

    1. Install Velero with [Restic](https://restic.net/) so you can create PV snapshots as well:

        ```bash
        BUCKET=bank-vaults-velero
        REGION=eu-north-1
        KMS_KEY_ID=alias/bank-vaults-velero
        SECRET_FILE=~/.aws/credentials

        helm upgrade --install velero --namespace velero \
                  --set configuration.provider=aws \
                  --set-file credentials.secretContents.cloud=${SECRET_FILE} \
                  --set deployRestic=true \
                  --set configuration.backupStorageLocation.name=aws \
                  --set configuration.backupStorageLocation.bucket=${BUCKET} \
                  --set configuration.backupStorageLocation.config.region=${REGION} \
                  --set configuration.backupStorageLocation.config.kmsKeyId=${KMS_KEY_ID} \
                  --set configuration.volumeSnapshotLocation.name=aws \
                  --set configuration.volumeSnapshotLocation.config.region=${REGION} \
                  --set "initContainers[0].name"=velero-plugin-for-aws \
                  --set "initContainers[0].image"=velero/velero-plugin-for-aws:v1.2.1 \
                  --set "initContainers[0].volumeMounts[0].mountPath"=/target \
                  --set "initContainers[0].volumeMounts[0].name"=plugins \
                  vmware-tanzu/velero
        ```

1. Install the vault-operator to the cluster:

    ```bash
    helm upgrade --install vault-operator oci://ghcr.io/bank-vaults/helm-charts/vault-operator

    kubectl apply -f operator/deploy/rbac.yaml
    kubectl apply -f operator/deploy/cr-raft.yaml
    ```

    > Note: The Vault CR in cr-raft.yaml has a special flag called `veleroEnabled`. This is useful for file-based Vault storage backends (`file`, `raft`), see the [Velero documentation](https://velero.io/docs/v1.2.0/hooks/):

    ```yaml
      # Add Velero fsfreeze sidecar container and supporting hook annotations to Vault Pods:
      # https://velero.io/docs/v1.2.0/hooks/
      veleroEnabled: true
    ```

1. Create a backup with the [Velero CLI](https://velero.io/docs/v1.5/basic-install/#install-the-cli) or with the predefined Velero Backup CR:

    ```bash
    velero backup create --selector vault_cr=vault vault-1

    # OR

    kubectl apply -f https://raw.githubusercontent.com/banzaicloud/bank-vaults/master/examples/backup/backup.yaml
    ```

    > Note: For a daily scheduled backup, see [schedule.yaml](https://raw.githubusercontent.com/banzaicloud/bank-vaults/master/examples/backup/schedule.yaml).

1. Check that the Velero backup got created successfully:

    ```bash
    velero backup describe --details vault-1
    ```

    Expected output:

    ```shell
    Name:         vault-1
    Namespace:    velero
    Labels:       velero.io/backup=vault-1
                  velero.io/pv=pvc-6eb4d9c1-25cd-4a28-8868-90fa9d51503a
                  velero.io/storage-location=default
    Annotations:  <none>

    Phase:  Completed

    Namespaces:
      Included:  *
      Excluded:  <none>

    Resources:
      Included:        *
      Excluded:        <none>
      Cluster-scoped:  auto

    Label selector:  vault_cr=vault

    Storage Location:  default

    Snapshot PVs:  auto

    TTL:  720h0m0s

    Hooks:  <none>

    Backup Format Version:  1

    Started:    2020-01-29 14:17:41 +0100 CET
    Completed:  2020-01-29 14:17:45 +0100 CET

    Expiration:  2020-02-28 14:17:41 +0100 CET
    ```

## Test the backup

1. To emulate a catastrophe, remove Vault entirely from the cluster:

    ```bash
    kubectl delete vault -l vault_cr=vault
    kubectl delete pvc -l vault_cr=vault
    ```

1. Now restore Vault from the backup.

    1. Scale down the vault-operator, so it won't reconcile during the restore process:

        ```bash
        kubectl scale deployment vault-operator --replicas 0
        ```

    1. Restore all Vault-related resources from the backup:

        ```bash
        velero restore create --from-backup vault-1
        ```

    1. Check that the restore has finished properly:

        ```bash
        velero restore get
        NAME                    BACKUP   STATUS      WARNINGS   ERRORS   CREATED                         SELECTOR
        vault1-20200129142409   vault1   Completed   0          0        2020-01-29 14:24:09 +0100 CET   <none>
        ```

    1. Check that the Vault cluster got actually restored:

        ```bash
        kubectl get pods
        NAME                                READY   STATUS    RESTARTS   AGE
        vault-0                             4/4     Running   0          1m42s
        vault-1                             4/4     Running   0          1m42s
        vault-2                             4/4     Running   0          1m42s
        vault-configurer-5499ff64cb-g75vr   1/1     Running   0          1m42s
        ```

    1. Scale the operator back after the restore process:

        ```bash
        kubectl scale deployment vault-operator --replicas 1
        ```

1. Delete the backup if you don't wish to keep it anymore:

    ```bash
    velero backup delete vault-1
    ```
