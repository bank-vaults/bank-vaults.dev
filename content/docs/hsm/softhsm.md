---
title: SoftHSM support for testing
linktitle: SoftHSM
weight: 200
---

You can use [SoftHSMv2](https://github.com/opendnssec/SoftHSMv2) to implement and test software interacting with PKCS11 implementations. You can install it on macOS by running the following commands:

```bash
# Initializing SoftHSM to be able to create a working example (only for dev),
# sharing the HSM device is emulated with a pre-created keypair in the image.
brew install softhsm
softhsm2-util --init-token --free --label bank-vaults --so-pin banzai --pin banzai
pkcs11-tool --module /usr/local/lib/softhsm/libsofthsm2.so --keypairgen --key-type rsa:2048 --pin banzai --token-label bank-vaults --label bank-vaults
```

To interact with SoftHSM when using the `vault-operator`, include the following `unsealConfig` snippet in the Vault CR:

```yaml
  # This example relies on the SoftHSM device initialized in the Docker image.
  unsealConfig:
    hsm:
      # The HSM SO module path (softhsm is built into the bank-vaults image)
      modulePath: /usr/lib/softhsm/libsofthsm2.so 
      tokenLabel: bank-vaults
      pin: banzai
      keyLabel: bank-vaults
```

To run the whole SoftHSM based example in Kubernetes, run the following commands:

```bash
kubectl create namespace vault-infra
helm upgrade --install vault-operator oci://ghcr.io/bank-vaults/helm-charts/vault-operator --namespace vault-infra
kubectl apply -f https://raw.githubusercontent.com/banzaicloud/bank-vaults/master/operator/deploy/cr-hsm-softhsm.yaml
```
