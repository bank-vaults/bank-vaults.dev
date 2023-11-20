---
title: NitroKey HSM support (OpenSC)
linktitle: Nitrokey
weight: 100
aliases:
- /docs/hsm/nitrokey-opensc/
---

[Nitrokey HSM](https://www.nitrokey.com/) is a USB HSM device based on the [OpenSC project](https://github.com/OpenSC/OpenSC). We are using NitroKey to develop real hardware-based HSM support for Bank-Vaults. This device is not a cryptographic accelerator, only key generation and the private key operations (sign and decrypt) are supported. Public key operations should be done by extracting the public key and working on the computer, and this is how it is implemented in Bank-Vaults. It is not possible to extract private keys from NitroKey HSM, the device is tamper-resistant.

This device supports only RSA based encryption/decryption, and thus this is implemented in Bank-Vaults currently. It supports ECC keys as well, but only for sign/verification operations.

To start using a NitroKey HSM, complete the following steps.

1. Install OpenSC and initialize the NitroKey HSM stick:

    ```bash
    brew install opensc
    sc-hsm-tool --initialize --label bank-vaults --pin banzai --so-pin banzaicloud
    pkcs11-tool --module /usr/local/lib/opensc-pkcs11.so --keypairgen --key-type rsa:2048 --pin banzai --token-label bank-vaults --label bank-vaults
    ```

1. Check that you got a keypair object in slot 0:

    ```bash
    pkcs11-tool --list-objects


    Using slot 0 with a present token (0x0)
    Public Key Object; RSA 2048 bits
      label:      bank-vaults
      ID:         a9548075b20243627e971873826ead172e932359
      Usage:      encrypt, verify, wrap
      Access:     none
    ```

    ```bash
    pkcs15-tool --list-keys

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

1. If you are testing the HSM on macOS, [setup minikube](#nitrokey-minikube). Otherwise, continue with the next step.

1. Configure the operator to use NitroKey HSM for unsealing.

    You must adjust the `unsealConfig` section in the vault-operator configuration, so the operator can communicate with OpenSC HSM devices correctly. Adjust your configuration based on the following snippet:

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

1. [Configure your Kubernetes node](#node-setup) that has the HSM attached so Bank-Vaults can access it.

## Setup on Minikube for testing (optional) {#nitrokey-minikube}

On macOS where you run Docker in VMs you need to do some extra steps before mounting your HSM device to Kubernetes.
Complete the following steps to mount NitroKey into the `minikube` Kubernetes cluster:

1. Make sure that the Oracle VM VirtualBox Extension Pack for USB 2.0 support is installed.

    ```bash
    VBoxManage list extpacks
    ```

1. Remove the HSM device from your computer if it is already plugged in.

1. Specify VirtualBox as the VM backend for Minikube.

    ```bash
    minikube config set vm-driver virtualbox
    ```

1. Create a minikube cluster with the virtualbox driver and stop it, so you can modify the VM.

    ```bash
    minikube start
    minikube stop
    ```

1. Enable USB 2.0 support for the minikube VM.

    ```bash
    VBoxManage modifyvm minikube --usbehci on
    ```

1. Find the vendorid and productid for your Nitrokey HSM device.

    ```bash
    VBoxManage list usbhost

    VENDORID=0x20a0
    PRODUCTID=0x4230
    ```

1. Create a filter for it.

    ```bash
    VBoxManage usbfilter add 1 --target minikube --name "Nitrokey HSM" --vendorid ${VENDORID} --productid ${PRODUCTID}
    ```

1. Restart the minikube VM.

    ```bash
    minikube start
    ```

1. Plug in the USB device.

1. Check that minikube captured your NitorKey HSM.

    ```bash
    minikube ssh lsusb | grep ${VENDORID:2}:${PRODUCTID:2}
    ```

Now your `minikube` Kubernetes cluster has access to the HSM device through USB.

## Kubernetes node setup {#node-setup}

Some HSM vendors offer network daemons to enhance the reach of their HSM equipment to different servers. Unfortunately, there is no networking standard defined for PKCS11 access and thus currently Bank-Vaults has to be scheduled to the same node where the HSM device is attached directly (if not using a Cloud HSM).

Since the HSM is a hardware device connected to a physical node, Bank-Vaults has to find its way to that node. To make this work, create an HSM [extended resource](https://kubernetes.io/docs/tasks/administer-cluster/extended-resource-node/) on the Kubernetes nodes for which the HSM device is plugged in. Extended resources must be advertised in integer amounts, for example, a Node can advertise four HSM devices, but not 4.5.

1. You need to patch the node to specify that it has an HSM device as a resource.
    Because of the integer constraint and because all Bank-Vaults related Pods has to land on a Node where an HSM resource is available we need to advertise two units for 1 device, one will be allocated by each Vault Pod and one by the Configurer. If you would like to run Vault in HA mode - multiple Vault instances in different nodes - you will need multiple HSM devices plugged into those nodes, having the same key and slot setup.

    ```bash
    kubectl proxy &

    NODE=minikube

    curl --header "Content-Type: application/json-patch+json" \
        --request PATCH \
        --data '[{"op": "add", "path": "/status/capacity/nitrokey.com~1hsm", "value": "2"}]' \
        http://localhost:8001/api/v1/nodes/${NODE}/status
    ```

    From now on, you can request the `nitrokey.com/hsm` resource [in the PodSpec](https://kubernetes.io/docs/tasks/configure-pod-container/extended-resource/)
1. Include the `nitrokey.com/hsm` resource in your PodSpec:

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

1. Apply the modified setup from scratch:

    ```bash
    kubectl delete vault vault
    kubectl delete pvc vault-file-vault-0
    kubectl delete secret vault-unseal-keys
    kubectl apply -f https://raw.githubusercontent.com/bank-vaults/vault-operator/v{{< param "latest_version" >}}/deploy/examples/cr-hsm-nitrokey.yaml
    ```

1. Check the logs that unsealing uses the NitroKey HSM device. Run the following command:

    ```bash
    kubectl logs -f vault-0 bank-vaults
    ```

    The output should be something like:

    ```bash
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

1. Find the unseal keys and the root token on the HSM:

    ```bash
    pkcs11-tool --list-objects
    ```

    Expected output:

    ```bash
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

1. If you don't need the encryption keys or the unseal keys on the HSM anymore, you can delete them with the following commands:

    ```bash
    PIN=banzai

    # Delete the unseal keys and the root token
    for label in "vault-test" "vault-root" "vault-unseal-0" "vault-unseal-1" "vault-unseal-2" "vault-unseal-3" "vault-unseal-4"
    do
      pkcs11-tool --delete-object --type data --label ${label} --pin ${PIN}
    done

    # Delete the encryption key
    pkcs11-tool --delete-object --type privkey --label bank-vaults --pin ${PIN}
    ```
