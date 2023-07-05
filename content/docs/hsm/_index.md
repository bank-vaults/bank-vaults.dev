---
title: HSM Support
weight: 690
---

Bank-Vaults offers a lot of alternatives for encrypting and storing the `unseal-keys` and the `root-token` for Vault. One of the encryption technics is the HSM - Hardware Security Module. HSM offers an industry-standard way to encrypt your data in on-premise environments.

You can use a Hardware Security Module (HSM) to generate and store the private keys used by Bank-Vaults. Some articles still point out the speed of HSM devices as their main selling point, but an average PC can do more cryptographic operations. Actually, the main benefit is from the security point of view. An HSM protects your private keys and handles cryptographic operations, which allows the encryption of protected information without exposing the private keys (they are not extractable). Bank-Vaults currently supports the [PKCS11](https://en.wikipedia.org/wiki/PKCS_11) software standard to communicate with an HSM. Fulfilling compliance requirements (for example, PCI DSS) is also a great benefit of HSMs, so from now on you can achieve that with Bank-Vaults.

## Implementation in Bank-Vaults

![Vault HSM](/img/hsm.png)

To support HSM devices for encrypting unseal-keys and root-tokens, Bank-Vaults:

- implements an encryption/decryption `Service` named `hsm` in the `bank-vaults` CLI,
- the `bank-vaults` Docker image now includes the SoftHSM (for testing) and the OpenSC tooling,
- the operator is aware of HSM and its nature.

The HSM offers an encryption mechanism, but the unseal-keys and root-token have to be stored somewhere after they got encrypted. Currently there are two possible solutions for that:

- Some HSM devices can store a limited quantity of arbitrary data (like Nitrokey HSM), and Bank-Vaults can store the unseal-keys and root-token here.
- If the HSM does not support that, Bank-Vaults uses the HSM to encrypt the unseal-keys and root-token, then stores them in [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/). We believe that it is safe to store these keys in Kubernetes Secrets in encrypted format.

Bank-Vaults offers the ability to use the pre-created the cryptographic encryption keys on the HSM device, or generate a key pair on the fly if there isn't any with the specified label in the specified slot.

Since Bank-Vaults is written in Go, it uses the [github.com/miekg/pkcs11](https://github.com/miekg/pkcs11) wrapper to pull in the PKCS11 library, to be more precise the `p11` high-level wrapper .

## Supported HSM solutions

Bank-Vaults currently supports the following HSM solutions:

- [SoftHSM]({{< relref "/docs/hsm/softhsm.md" >}}), recommended for testing
- [NitroKey HSM]({{< relref "/docs/hsm/nitrokey-opensc.md" >}}).
- AWS CloudHSM supports the PKCS11 API as well, so it probably works, though it needs a custom Docker image.
