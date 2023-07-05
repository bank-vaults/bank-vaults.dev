---
---
## Deploy the mutating webhook

You can deploy the Vault Secrets Webhook using Helm. Note that:

- The Helm chart of the vault-secrets-webhook contains the templates of the required permissions as well.
- The deployed RBAC objects contain the necessary permissions fo running the webhook.

### Prerequisites

- The user you use for deploying the chart to the Kubernetes cluster must have cluster-admin privileges.
- The chart requires Helm 3.
- To interact with Vault (for example, for testing), the *vault* command line client must be installed on your computer.
- You have deployed Vault with the operator and configured your Vault client to access it, as described in [Deploy a local Vault operator]({{< relref "/docs/installing/_index.md#deploy-operator" >}}).

### Deploy the webhook

1. Create a namespace for the webhook and add a label to the namespace, for example, *vault-infra*:

    ```bash
    kubectl create namespace vault-infra
    kubectl label namespace vault-infra name=vault-infra
    ```

1. Deploy the vault-secrets-webhook chart:

    ```bash
    helm repo add banzaicloud-stable https://kubernetes-charts.banzaicloud.com
    helm upgrade --namespace vault-infra --install vault-secrets-webhook banzaicloud-stable/vault-secrets-webhook
    ```

    For further details, see the [webhook's Helm chart repository](https://github.com/bank-vaults/vault-secrets-webhook/tree/main/deploy/charts/vault-secrets-webhook).

1. Check that the pods are running:

    ```bash
    kubectl get pods --namespace vault-infra
    NAME                                     READY   STATUS    RESTARTS   AGE
    vault-secrets-webhook-58b97c8d6d-qfx8c   1/1     Running   0          22s
    vault-secrets-webhook-58b97c8d6d-rthgd   1/1     Running   0          22s
    ```

1. Write a secret into Vault (the Vault CLI must be installed on your computer):

    ```bash
    vault kv put secret/demosecret/aws AWS_SECRET_ACCESS_KEY=s3cr3t
    ```

    Expected output:

    ```bash
    Key              Value
    ---              -----
    created_time     2020-11-04T11:39:01.863988395Z
    deletion_time    n/a
    destroyed        false
    version          1
    ```

1. Apply the following deployment to your cluster. The webhook will mutate this deployment because it has an environment variable having a value which is a reference to a path in Vault:

    {{< include-code "webhook-demo-deployment.yaml" "yaml" >}}

1. Check the mutated deployment.

    ```bash
    kubectl describe deployment vault-test
    ```

    The output should look similar to the following:

    ```yaml
    Name:                   vault-test
    Namespace:              default
    CreationTimestamp:      Wed, 04 Nov 2020 12:44:18 +0100
    Labels:                 <none>
    Annotations:            deployment.kubernetes.io/revision: 1
    Selector:               app.kubernetes.io/name=vault
    Replicas:               1 desired | 1 updated | 1 total | 1 available | 0 unavailable
    StrategyType:           RollingUpdate
    MinReadySeconds:        0
    RollingUpdateStrategy:  25% max unavailable, 25% max surge
    Pod Template:
      Labels:           app.kubernetes.io/name=vault
      Annotations:      vault.security.banzaicloud.io/vault-addr: https://vault:8200
                        vault.security.banzaicloud.io/vault-agent: false
                        vault.security.banzaicloud.io/vault-path: kubernetes
                        vault.security.banzaicloud.io/vault-role: default
                        vault.security.banzaicloud.io/vault-skip-verify: false
                        vault.security.banzaicloud.io/vault-tls-secret: vault-tls
      Service Account:  default
      Containers:
       alpine:
        Image:      alpine
        Port:       <none>
        Host Port:  <none>
        Command:
          sh
          -c
          echo $AWS_SECRET_ACCESS_KEY && echo going to sleep... && sleep 10000
        Environment:
          AWS_SECRET_ACCESS_KEY:  vault:secret/data/demosecret/aws#AWS_SECRET_ACCESS_KEY
        Mounts:                   <none>
      Volumes:                    <none>
    Conditions:
      Type           Status  Reason
      ----           ------  ------
      Available      True    MinimumReplicasAvailable
      Progressing    True    NewReplicaSetAvailable
    OldReplicaSets:  <none>
    NewReplicaSet:   vault-test-55c569f9 (1/1 replicas created)
    Events:
      Type    Reason             Age   From                   Message
      ----    ------             ----  ----                   -------
      Normal  ScalingReplicaSet  29s   deployment-controller  Scaled up replica set vault-test-55c569f9 to 1
    ```

    As you can see, the original environment variables in the definition are unchanged, and the sensitive value of the AWS_SECRET_ACCESS_KEY variable is only visible within the alpine container.
