---
title: Decrypt the root token
weight: 5000
---

If you want to decrypt the root token for some reason, see the section corresponding to the storage provider you used to store the token.

## AWS

To use the KMS-encrypted root token with Vault CLI:

Required CLI tools:

- aws

Steps:

1. Download and decrypt the root token (and the unseal keys, but that is not mandatory) into a file on your local file system:

    ```bash
    BUCKET=bank-vaults-0
    REGION=eu-central-1

    for key in "vault-root" "vault-unseal-0" "vault-unseal-1" "vault-unseal-2" "vault-unseal-3" "vault-unseal-4"
    do
        aws s3 cp s3://${BUCKET}/${key} .

        aws kms decrypt \
            --region ${REGION} \
            --ciphertext-blob fileb://${key} \
            --encryption-context Tool=bank-vaults \
            --output text \
            --query Plaintext | base64 -d > ${key}.txt

        rm ${key}
    done
    ```

1. Save it as an environment variable:

    ```bash
    export VAULT_TOKEN="$(cat vault-root.txt)"
    ```

## Google Cloud

To use the KMS-encrypted root token with vault CLI:

Required CLI tools:

- `gcloud`
- `gsutil`

```bash
GOOGLE_PROJECT="my-project"
GOOGLE_REGION="us-central1"
BUCKET="bank-vaults-bucket"
KEYRING="beta"
KEY="beta"

export VAULT_TOKEN=$(gsutil cat gs://${BUCKET}/vault-root | gcloud kms decrypt \
                     --project ${GOOGLE_PROJECT} \
                     --location ${GOOGLE_REGION} \
                     --keyring ${KEYRING} \
                     --key ${KEY} \
                     --ciphertext-file - \
                     --plaintext-file -)
```

## Kubernetes

There is a Kubernetes Secret backed unseal storage in Bank-Vaults, you should be aware of that Kubernetes Secrets are base64 encoded only if you are not using a [EncryptionConfiguration](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/) in your Kubernetes cluster.

```bash
VAULT_NAME="vault"

export VAULT_TOKEN=$(kubectl get secrets ${VAULT_NAME}-unseal-keys -o jsonpath={.data.vault-root} | base64 -d)
```
