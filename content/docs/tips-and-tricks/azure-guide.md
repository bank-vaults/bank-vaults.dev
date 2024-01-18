---
title: Guide - Run Bank-Vaults stack on Azure
linktitle: Azure guide
---

In this guide, you will:

- start an AKS cluster,
- deploy the [Vault Operator](https://github.com/bank-vaults/vault-operator) and the [Vault Secrets Webhook](https://github.com/bank-vaults/vault-secrets-webhook),
- create a Vault instance configured to use [Azure Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/) to store Vault's root and unseal tokens,
- configure [Azure Storage](https://learn.microsoft.com/en-us/azure/storage/) to persist Vault's data, and
- configure the [Azure Auth method](https://developer.hashicorp.com/vault/docs/auth/azure) for the Webhook to authenticate against Vault.

## Prerequisites

- Access to Azure cloud with a subscription
- `azure-cli` installed on your machine

## Step 1: Create Azure resources

Ensure that you are logged in to your Azure account with `azure-cli`:

```bash
az login --tenant <YourTenantName>
```

Expected output:

```json
[
  {
    "cloudName": "AzureCloud",
    "homeTenantId": "<YourHomeTenantId>",
    "id": "<YourSubscriptionId>",
    "isDefault": true,
    "managedByTenants": [],
    "name": "<YourSubscriptionName>",
    "state": "Enabled",
    "tenantId": "<YourTenantId>",
    "user": {
      "name": "<YourUserName>",
      "type": "user"
    }
  }
]
```

Save `<YourSubscriptionId>` and `<YourTenantId>` as it will be required later.

If you don't already have a `Resource group` you would like to use, create a new one using:

```bash
az group create --name "bank-vaults-test-rg" --location "EastUS"
{...}
```

### Create an AKS cluster

```bash
# create cluster
az aks create --resource-group "bank-vaults-test-rg" --name "bank-vaults-test-cluster" --generate-ssh-keys
{...}

# write credentials to kubeconfig
az aks get-credentials --resource-group "bank-vaults-test-rg" --name "bank-vaults-test-cluster"

# if you need to look at cluster information again
az aks show --resource-group "bank-vaults-test-rg" --name "bank-vaults-test-cluster"
```

### Create an App Registration and a Client secret

This **App Registration** resource will be used as the resource for generating MSI access tokens for authentication. A more detailed guide for this can be found [here](https://learn.microsoft.com/en-us/azure/healthcare-apis/register-application-cli-rest).

```bash
# create App Registration and only return with its Application Id
az ad app create --display-name "bank-vaults-test-ar" --query appId --output tsv
<YourAppRegistrationApplicationId>

# create Service Principal for your App Registration
az ad sp create --id "<YourAppRegistrationApplicationId>" --query id --output tsv
<YourEnterpriseApplicationObjectID>

# create secret
# The output includes credentials that you must protect. Be sure that you do not include these credentials in your code or check the credentials into your source control. For more information, see https://aka.ms/azadsp-cli
az ad app credential reset --id "<YourAppRegistrationApplicationId>" --append --display-name "bank-vaults-test-secret" --query password --output tsv
<YourAppRegistrationClientSecret>

# authorize the Service Principal to read resources in your Resource Group
az role assignment create --assignee "<YourEnterpriseApplicationObjectID>" --scope "/subscriptions/<YourSubscriptionId>/resourceGroups/MC_bank-vaults-test-rg_bank-vaults-test-cluster_eastus" --role Reader
{...}
```

### Create an Azure Key Vault and permit access for the AKS cluster

```bash
# create Azure Key Vault
az keyvault create --resource-group "bank-vaults-test-rg" --name "bank-vaults-test-kv" --location "EastUS"
{...}

# get the AKS cluster's Object ID
az aks show --resource-group "bank-vaults-test-rg" --name "bank-vaults-test-cluster" --query "identityProfile.kubeletidentity.objectId" --output tsv
<YourAKSClusterObjectID>

# set policy
az keyvault set-policy --name "bank-vaults-test-kv" --object-id <YourAKSClusterObjectID> --secret-permissions all --key-permissions all --certificate-permissions all
{...}
```

### Create Storage Account and a Container

```bash
# create storage account
az storage account create \
  --name "bankvaultsteststorage" \
  --resource-group "bank-vaults-test-rg" \
  --location "EastUS" \
  --sku "Standard_RAGRS" \
  --kind "StorageV2"
{...}

# get storage account key
az storage account keys list --account-name "bankvaultsteststorage" --query "[0].value" --output tsv
<YourStorageAccountKey>

# create container
az storage container create \
    --name "bank-vaults-test-container" \
    --account-name "bankvaultsteststorage"
{...}
```

## Step 2: Install Bank-Vaults components

This step will:
- [install](https://bank-vaults.dev/docs/operator/#deploy-operator) the [Vault Operator](https://github.com/bank-vaults/vault-operator)
- [install](https://bank-vaults.dev/docs/mutating-webhook/deploy/#deploy-the-mutating-webhook) the mutating [Webhook](https://github.com/bank-vaults/vault-secrets-webhook) on the created AKS cluster
- create a `Vault` custom resource to deploy Vault that uses Azure resources for authentication, and to store generated secrets and Vault's data

### Install Vault Operator

```bash
# install Vault Operator
helm upgrade --install --wait vault-operator oci://ghcr.io/bank-vaults/helm-charts/vault-operator
```

### Install Vault Secrets Webhook

```bash
# create a new namespace and install the Vault Secrets Webhook in it
kubectl create namespace vault-infra
kubectl label namespace vault-infra name=vault-infra

helm upgrade --install --wait vault-secrets-webhook oci://ghcr.io/bank-vaults/helm-charts/vault-secrets-webhook --namespace vault-infra
```

### Start a pre-configured Vault instance

Create a `cr-azure.yaml` resource definition file as defined below. Replace `<YourStorageAccountKey>`, `<YourTenantId>`, `<YourAppRegistrationObjectId>`, `<YourAppRegistrationClientSecret>`, `<YourSubscriptionId>` and `<YourAKSClusterObjectID>` with the values acquired in the previous steps.
Make sure to also update the `spec.unsealConfig.azure.keyVaultName`, `spec.config.storage.azure.accountName`, `spec.config.storage.azure.container` fields other names were used for these Azure resources compared to this guide.

The Vault Operator can put some initial secrets into Vault when configuring it (`spec.externalConfig.startupSecrets`), which will be used to test the initial deployment.

```yaml
apiVersion: "vault.banzaicloud.com/v1alpha1"
kind: "Vault"
metadata:
  name: "vault"
spec:
  size: 1
  image: "hashicorp/vault:1.14.1"

  # Describe where you would like to store the Vault unseal keys and root token in Azure KeyVault.
  unsealConfig:
    azure:
      keyVaultName: "bank-vaults-test-kv" # name of the Key Vault you created

  # Specify the ServiceAccount where the Vault Pod and the Bank-Vaults configurer/unsealer is running
  serviceAccount: vault

  # A YAML representation of a final vault config file. This config defines the Azure as backing store for Vault.
  # See https://www.vaultproject.io/docs/configuration/ for more information.
  config:
    storage:
      azure:
        accountName: "bankvaultsteststorage" # name of the storage you created
        accountKey: "<YourStorageAccountKey>" # storage account key you listed in a previous step
        container: "bank-vaults-test-container" # name of the container you created
        environment: "AzurePublicCloud"
    listener:
      tcp:
        address: "0.0.0.0:8200"
        tls_cert_file: /vault/tls/server.crt
        tls_key_file: /vault/tls/server.key
    api_addr: https://vault.default:8200
    telemetry:
      statsd_address: localhost:9125
    ui: true

  # See: https://banzaicloud.com/docs/bank-vaults/cli-tool/#example-external-vault-configuration
  # The repository also contains a lot examples in the deploy/ and operator/deploy directories.
  externalConfig:
    policies:
      - name: allow_secrets
        rules: path "secret/*" {
          capabilities = ["create", "read", "update", "delete", "list"]
          }
    auth:
      - type: azure
        path: azure
        config:
          tenant_id: "<YourTenantId>"
          resource: "https://management.azure.com/"
          client_id: "<YourAppRegistrationApplicationId>"  # App Registration Application (client) ID
          client_secret: "<YourAppRegistrationClientSecret>"  # App Registration generated secret value
        roles:
        # Add roles for azure identities
        # See https://www.vaultproject.io/api/auth/azure/index.html#create-role
          - name: default
            policies: allow_secrets
            bound_subscription_ids:
              - "<YourSubscriptionId>"
            bound_service_principal_ids:
              - "<YourAKSClusterObjectID>"  # AKS cluster Object ID

    secrets:
      - path: secret
        type: kv
        description: General secrets.
        options:
          version: 2

    # Allows writing some secrets to Vault (useful for development purposes).
    # See https://www.vaultproject.io/docs/secrets/kv/index.html for more information.
    startupSecrets:
      - type: kv
        path: secret/data/accounts/aws
        data:
          data:
            AWS_ACCESS_KEY_ID: secretId
            AWS_SECRET_ACCESS_KEY: s3cr3t
      - type: kv
        path: secret/data/dockerrepo
        data:
          data:
            DOCKER_REPO_USER: dockerrepouser
            DOCKER_REPO_PASSWORD: dockerrepopassword
      - type: kv
        path: secret/data/mysql
        data:
          data:
            MYSQL_ROOT_PASSWORD: s3cr3t
            MYSQL_PASSWORD: 3xtr3ms3cr3t
```

Once the resource definition is filled out with proper data, apply it together after adding required RBAC rules:

```bash
# apply RBAC rules
kubectl kustomize https://github.com/bank-vaults/vault-operator/deploy/rbac | kubectl apply -f -

# apply deployment manifest
kubectl apply -f cr-azure.yaml
```

After the Vault instance has been successfully created, proceed to access Vault with the Vault CLI from the terminal by running:

```bash
export VAULT_TOKEN=$(az keyvault secret download --file azure --name vault-root --vault-name bank-vaults-test-kv; cat azure; rm azure)

kubectl get secret vault-tls -o jsonpath="{.data.ca\.crt}" | base64 --decode > $PWD/vault-ca.crt
export VAULT_CACERT=$PWD/vault-ca.crt

export VAULT_ADDR=https://127.0.0.1:8200

kubectl port-forward service/vault 8200 &
```

## Step 3: Create a deployment that uses Azure auth

Finally, you can create a test deployment and check if the secrets were successfully injected into its pods!

Create a resource definition file called `deployment.yaml` with the following content:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: bank-vaults-test
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: bank-vaults-test
  template:
    metadata:
      labels:
        app.kubernetes.io/name: bank-vaults-test
      annotations:
        vault.security.banzaicloud.io/vault-addr: "https://vault:8200"
        vault.security.banzaicloud.io/vault-skip-verify: "true"
        vault.security.banzaicloud.io/vault-role: "default"
        vault.security.banzaicloud.io/vault-path: "azure"
        vault.security.banzaicloud.io/vault-auth-method: "azure"
    spec:
      containers:
        - name: alpine
          image: alpine
          command:
            - "sh"
            - "-c"
            - "echo $AWS_SECRET_ACCESS_KEY && echo $MYSQL_PASSWORD && echo going to sleep... && sleep 10000"
          env:
            - name: AWS_SECRET_ACCESS_KEY
              value: vault:secret/data/accounts/aws#AWS_SECRET_ACCESS_KEY
            - name: MYSQL_PASSWORD
              value: vault:secret/data/mysql#${.MYSQL_PASSWORD}
          resources:
            limits:
              memory: "128Mi"
              cpu: "100m"
```

Apply it and then watch for its logs - are the secrets injected by the Webhook present?

```bash
kubectl appply -f deployment.yaml

kubectl logs -l app.kubernetes.io/name=bank-vaults-test --follow
```

Expected output:

```bash
...
s3cr3t
3xtr3ms3cr3t
going to sleep...
```

## Step 4: Clean up

To cleanup Azure resources created in the previous steps, you might want to remove them to reduce cloud costs:

```bash
# delete Resource group with the AKS Cluster, Key Vault, Storage and Container etc.
az group delete --name "bank-vaults-test-rg"


# delete App Registration
az ad app delete --id "<YourAppRegistrationApplicationId>"
```
