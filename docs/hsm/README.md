# HSM Support

Bank-Vaults offers a lot of alternatives for encrypting and storing the `unseal-keys` and the `root-token` for Vault. One of the encryption technics is the HSM - Hardware Security Module. HSM offers an industry-standard way to encrypt your data in on-premise environments.

You can use a Hardware Security Module (HSM) to generate and store the private keys used by Bank-Vaults. Some articles still point out the speed of HSM devices as their main selling point, but an average PC can do more cryptographic operations. Rather the main benefit is from the security point of view. An HSM protects your private keys and handles cryptographic operations, which allows the encryption of protected information without exposing the private keys (the are not extractable) Bank-Vaults currently supports the [PKCS11](https://en.wikipedia.org/wiki/PKCS_11) software standard to communicate with an HSM. Fulfilling Compliance Requirements (e.g. PCI DSS) is also a great benefit of HSMs, so from now on you can achieve that with Bank-Vaults.

## Implementation in Bank-Vaults

To support HSM devices for encrypting unseal-keys and root-tokens Bank-Vaults had to be changed at a few places:
- a new encryption/decryption `Service` had to be implemented, named `hsm` in the `bank-vaults` CLI
- the `bank-vaults` Docker image now includes the SoftHSM (for testing) and the OpenSC tooling
- the operator had to become aware of HSM and its nature

The HSM offers an encryption mechanism, but the unseal-keys and root-token have to be stored somewhere after they got encrypted. Some HSM devices offer to store a limited quantity of arbitrary data (like Nitrokey HSM). Bank-Vaults additionally offers Kubernetes Secrets to storage backend the encrypted unseal keys. We think that after encryption is safe to store them Kubernetes Secrets in this form. In future versions, we will probably offer more storage backends, but currently, this fulfills our requirements.

Bank-Vaults offers the ability to use the pre-created the cryptographic encryption keys on the HSM device, or generate a key pair on the fly if there isn't any with the specified label in the specified slot.

Since Bank-Vaults is written in Go, we used the [github.com/miekg/pkcs11](https://github.com/miekg/pkcs11) wrapper to pull in the PKCS11 library, to be more precise the `p11` high-level wrapper which

> wraps `miekg/pkcs11` to make it easier to use and more idiomatic to Go, as compared with the more straightforward C wrapper that `miekg/pkcs11` presents.

This made our lives a lot easier, thanks to Miek Gieben.

## SoftHSM support for testing

[SoftHSMv2](https://github.com/opendnssec/SoftHSMv2) is a great piece of software developed by OpenDNSSEC. If you are planning to implement and test software interacting with PKCS11 implementations this is the way to go.

```bash
# Initializing SoftHSM to be able to create a working example (only for dev),
# sharing the HSM device is emulated with a pre-created keypair in the image.
brew install softhsm
softhsm2-util --init-token --free --label bank-vaults --so-pin banzai --pin banzai
pkcs11-tool --module /usr/local/lib/softhsm/libsofthsm2.so --keypairgen --key-type rsa:2048 --pin banzai --token-label bank-vaults --label bank-vaults
```

With the following `unsealConfig` snippet in the Vault CR (when using the `vault-operator`) you can interact with SoftHSM:

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

To run the whole SoftHSM based example in Kubernetes follow these steps:

```bash
kubectl create namespace vault-infra
helm upgrade --install vault-operator banzaicloud-stable/vault-operator --namespace vault-infra
kubectl apply -f https://raw.githubusercontent.com/banzaicloud/bank-vaults/master/operator/deploy/cr-hsm-softhsm.yaml
```

## NitroKey HSM support (OpenSC)

[Nitrokey HSM](https://www.nitrokey.com/) is a USB HSM device based on the [OpenSC project](https://github.com/OpenSC/OpenSC). We are using NitroKey to develop real hardware-based HSM support for Bank-Vaults. This device is not a cryptographic accelerator. Only key generation and the private key operations (sign and decrypt) are supported. Public key operations should be done by extracting the public key and working on the computer, and this is how it is implemented in Bank-Vaults. It is not possible to extract private keys from NitroKey HSM, the device is tamper-resistant.

This device supports only RSA based encryption/decryption, and thus this is implemented in Bank-Vaults currently. It supports ECC keys as well, but only for sign/verification operations.

Install OpenSC and initialize the NitroKey HSM stick:

```bash
brew install opensc
sc-hsm-tool --initialize --label bank-vaults --pin banzai --so-pin banzaicloud
pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so --keypairgen --key-type rsa:2048 --pin banzai --token-label bank-vaults --label bank-vaults
```
Check that in you got a keypair object in slot 0:

```bash
pkcs11-tool --list-objects
```
```
Using slot 0 with a present token (0x0)
Public Key Object; RSA 2048 bits
  label:      bank-vaults
  ID:         a9548075b20243627e971873826ead172e932359
  Usage:      encrypt, verify, wrap
  Access:     none
```

```bash
pkcs15-tool --list-keys
```
```
Using reader with a card: Nitrokey Nitrokey HSM
Private RSA Key [bank-vaults]
	Object Flags   : [0x03], private, modifiable
	Usage          : [0x0E], decrypt, sign, signRecover
	Access Flags   : [0x1D], sensitive, alwaysSensitive, neverExtract, local
	ModLength      : 2048
	Key ref        : 1 (0x01)
	Native         : yes
	Auth ID        : 01
	ID             : a9548075b20243627e971873826ead172e932359
	MD:guid        : a6b2832c-1dc5-f4ef-bb0f-7b3504f67015
```

### Setup on Minikube for testing (optional)

On OSX where you run Docker in VMs you need to do some extra steps before developing to mount your HSM device to Kubernetes, on Linux you can skip the next section, where we configure the HSM device.

We are going to use Minikube to test and validate the NitroKey setup, the following steps are needed to mount it into the `minikube` Kubernetes cluster:

```bash
# Specify VirtualBox as the VM backend
minikube config set vm-driver virtualbox

# You need to the Oracle VM VirtualBox Extension Pack for USB 2.0 support, make sure it is installed
VBoxManage list extpacks

# Create a minikube cluster with the virtualbox driver and stop it (we need to modify the VM)
minikube start
minikube stop

# Enable USB 2.0 support for the minikube VM
VBoxManage modifyvm minikube --usbehci on

# Find the vendorid and productid for your Nitrokey HSM device
VBoxManage list usbhost

VENDORID=0x20a0
PRODUCTID=0x4230

# Create a filter for it
VBoxManage usbfilter add 1 --target minikube --name "Nitrokey HSM" --vendorid ${VENDORID} --productid ${PRODUCTID}

# Restart the minikube VM
minikube start

# Plug in the USB device now to your computer

# Check that minikube captured your NitorKey HSM
minikube ssh lsusb | grep ${VENDORID:2}:${PRODUCTID:2}
```

Now your `minikube` Kubernetes cluster has access to the HSM device through USB.

### Configuring the operator to use NitroKey HSM based unsealing

In the vault-operator the `unsealConfig` becomes a bit different in for OpenSC HSM devices, there are certain things that the operator needs to be aware of to communicate with the device correctly:

```yaml
  # This example relies on an OpenSC HSM (NitroKey HSM) device initialized and plugged in to the Kubernetes Node.
  unsealConfig:
    hsm:
      # OpenSC daemon is needed in this case to communicate with the device
      daemon: true
      # The HSM SO module path (opensc is built into the bank-vaults image)
      modulePath: /usr/lib/opensc-pkcs11.so
      # For OpenSC slotId is the preferred way instead of tokenLabel
      # (OpenSC appends/prepends some extra stuff to labels)
      slotId: 0
      pin: banzai # This can be specified in the BANK_VAULTS_HSM_PIN environment variable as well, from a Secret
      keyLabel: bank-vaults
```

## Kubernetes node setup

Some HSM vendors offer network daemons to enhance the reach of their HSM equipment to different servers. Unfortunately, there is no networking standard defined for PKCS11 access and thus currently Bank-Vaults has to be scheduled to the same node where the HSM device is attached directly (if not using a Cloud HSM).

Since the HSM is a hardware device connected to a physical node, Bank-Vaults has to find its way to that node. To make this work, we create an HSM [extended resource](https://kubernetes.io/docs/tasks/administer-cluster/extended-resource-node/) on the Kubernetes nodes for which the HSM device is plugged in. Extended resources must be advertised in integer amounts. For example, a Node can advertise four HSM devices, but not 4.5.

We need to patch the node to specify that it has an HSM device as a resource. Because of the integer constraint and because all Bank-Vaults related Pods has to land on a Node where an HSM resource is available we need to advertise two units for 1 device, one will be allocated by each Vault Pod and one by the Configurer. If you would like to run Vault in HA mode - multiple Vault instances in different nodes - you will need multiple HSM devices plugged into those nodes, having the same key and slot setup.

```bash
kubectl proxy &

NODE=minikube

curl --header "Content-Type: application/json-patch+json" \
     --request PATCH \
     --data '[{"op": "add", "path": "/status/capacity/nitrokey.com~1hsm", "value": "2"}]' \
     http://localhost:8001/api/v1/nodes/${NODE}/status
```

This resource can be requested from now on [in the PodSpec](https://kubernetes.io/docs/tasks/configure-pod-container/extended-resource/):

```yaml
  # If using the NitroKey HSM example, that resource has to be part of the resource scheduling request.
  resources:
    hsmDaemon:
      requests:
        cpu: 100m
        memory: 64Mi
        nitrokey.com/hsm: 1
      limits:
        cpu: 200m
        memory: 128Mi
        nitrokey.com/hsm: 1
```

Apply the modified setup from scratch:

```bash
kubectl delete vault vault
kubectl delete pvc vault-file-vault-0
kubectl delete secret vault-unseal-keys
kubectl apply -f https://raw.githubusercontent.com/banzaicloud/bank-vaults/master/operator/deploy/cr-hsm-nitrokey.yaml
```

Check the logs that unsealing uses the NitroKey HSM device now:

```bash
kubectl logs -f vault-0 bank-vaults
```
```
time="2020-03-04T13:32:29Z" level=info msg="HSM Information {CryptokiVersion:{Major:2 Minor:20} ManufacturerID:OpenSC Project Flags:0 LibraryDescription:OpenSC smartcard framework LibraryVersion:{Major:0 Minor:20}}"
time="2020-03-04T13:32:29Z" level=info msg="HSM Searching for slot in HSM slots [{ctx:0xc0000c0318 id:0}]"
time="2020-03-04T13:32:29Z" level=info msg="found HSM slot 0 in HSM by slot ID"
time="2020-03-04T13:32:29Z" level=info msg="HSM TokenInfo {Label:bank-vaults (UserPIN)\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00 ManufacturerID:www.CardContact.de Model:PKCS#15 emulated SerialNumber:DENK0200074 Flags:1037 MaxSessionCount:0 SessionCount:0 MaxRwSessionCount:0 RwSessionCount:0 MaxPinLen:15 MinPinLen:6 TotalPublicMemory:18446744073709551615 FreePublicMemory:18446744073709551615 TotalPrivateMemory:18446744073709551615 FreePrivateMemory:18446744073709551615 HardwareVersion:{Major:24 Minor:13} FirmwareVersion:{Major:3 Minor:3} UTCTime:\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00}"
time="2020-03-04T13:32:29Z" level=info msg="HSM SlotInfo for slot 0: {SlotDescription:Nitrokey Nitrokey HSM (DENK02000740000         ) 00 00 ManufacturerID:Nitrokey Flags:7 HardwareVersion:{Major:0 Minor:0} FirmwareVersion:{Major:0 Minor:0}}"
time="2020-03-04T13:32:29Z" level=info msg="found objects with label \"bank-vaults\" in HSM"
time="2020-03-04T13:32:29Z" level=info msg="this HSM device doesn't support encryption, extracting public key and doing encrytion on the computer"
time="2020-03-04T13:32:29Z" level=info msg="no storage backend specified for HSM, using on device storage"
time="2020-03-04T13:32:29Z" level=info msg="joining leader vault..."
time="2020-03-04T13:32:29Z" level=info msg="vault metrics exporter enabled: :9091/metrics"
[GIN-debug] [WARNING] Running in "debug" mode. Switch to "release" mode in production.
 - using env:	export GIN_MODE=release
 - using code:	gin.SetMode(gin.ReleaseMode)

[GIN-debug] GET    /metrics                  --> github.com/gin-gonic/gin.WrapH.func1 (3 handlers)
[GIN-debug] Listening and serving HTTP on :9091
time="2020-03-04T13:32:30Z" level=info msg="initializing vault..."
time="2020-03-04T13:32:30Z" level=info msg="initializing vault"
time="2020-03-04T13:32:31Z" level=info msg="unseal key stored in key store" key=vault-unseal-0
time="2020-03-04T13:32:31Z" level=info msg="unseal key stored in key store" key=vault-unseal-1
time="2020-03-04T13:32:32Z" level=info msg="unseal key stored in key store" key=vault-unseal-2
time="2020-03-04T13:32:32Z" level=info msg="unseal key stored in key store" key=vault-unseal-3
time="2020-03-04T13:32:33Z" level=info msg="unseal key stored in key store" key=vault-unseal-4
time="2020-03-04T13:32:33Z" level=info msg="root token stored in key store" key=vault-root
time="2020-03-04T13:32:33Z" level=info msg="vault is sealed, unsealing"
time="2020-03-04T13:32:39Z" level=info msg="successfully unsealed vault"
```

Also. you will find the unseal keys and the root token on the HSM:

```bash
pkcs11-tool --list-objects
```
```
Using slot 0 with a present token (0x0)
Public Key Object; RSA 2048 bits
  label:      bank-vaults
  ID:         a9548075b20243627e971873826ead172e932359
  Usage:      encrypt, verify, wrap
  Access:     none
Data object 2168561792
  label:          'vault-test'
  application:    'vault-test'
  app_id:         <empty>
  flags:           modifiable
Data object 2168561168
  label:          'vault-unseal-0'
  application:    'vault-unseal-0'
  app_id:         <empty>
  flags:           modifiable
Data object 2168561264
  label:          'vault-unseal-1'
  application:    'vault-unseal-1'
  app_id:         <empty>
  flags:           modifiable
Data object 2168561360
  label:          'vault-unseal-2'
  application:    'vault-unseal-2'
  app_id:         <empty>
  flags:           modifiable
Data object 2168562304
  label:          'vault-unseal-3'
  application:    'vault-unseal-3'
  app_id:         <empty>
  flags:           modifiable
Data object 2168562400
  label:          'vault-unseal-4'
  application:    'vault-unseal-4'
  app_id:         <empty>
  flags:           modifiable
Data object 2168562496
  label:          'vault-root'
  application:    'vault-root'
  app_id:         <empty>
  flags:           modifiable
```

If you would like to clean up on the HSM after testing:

```bash
PIN=banzai

for label in "vault-test" "vault-root" "vault-unseal-0" "vault-unseal-1" "vault-unseal-2" "vault-unseal-3" "vault-unseal-4"
do
  pkcs11-tool --delete-object --type data --label ${label} --pin ${PIN}
done
```

## Additional HSM implementations

AWS CloudHSM supports the PKCS11 API as well, so it should probably work as well, though it needs a custom Docker image.
