---
title: Migrate unseal keys between cloud providers
weight: 5100
---

If you need to move your Vault instance from one provider or an external managed Vault, you have to:

1. Retrieve and decrypt the unseal keys (and optionally the root token) in the Bank-Vaults format. For details, see {{% xref "/docs/concepts/unseal-keys/decrypt-root-token.md" %}}.
1. Migrate the Vault storage data to the new provider. Use the [official migration command](https://developer.hashicorp.com/vault/docs/commands/operator/migrate) provided by Vault.

All examples assume that you have created files holding the root-token and the 5 unseal keys in plaintext:

- `vault-root.txt`
- `vault-unseal-0.txt`
- `vault-unseal-1.txt`
- `vault-unseal-2.txt`
- `vault-unseal-3.txt`
- `vault-unseal-4.txt`

## AWS

Move the above mentioned files to an AWS bucket and encrypt them with KMS before:

```bash
REGION=eu-central-1
KMS_KEY_ID=02a2ba49-42ce-487f-b006-34c64f4b760e
BUCKET=bank-vaults-1

for key in "vault-root" "vault-unseal-0" "vault-unseal-1" "vault-unseal-2" "vault-unseal-3" "vault-unseal-4"
do
    aws kms encrypt \
        --region ${REGION} --key-id ${KMS_KEY_ID} \
        --plaintext fileb://${key}.txt \
        --encryption-context Tool=bank-vaults \
        --output text \
        --query CiphertextBlob | base64 -d > ${key}

    aws s3 cp ./${key} s3://${BUCKET}/

    rm ${key} ${key}.txt
done
```
