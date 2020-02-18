---
title: Istio
weight: 200
---

Both the `vault-operator` and the `vault-secrets-webhook` can work on Istio enabled clusters quite well.

We are going to walk through 3 different scenarios here, namely:

- The namespace where your application is running has Istio injection enabled
- The namespace where Vault is running has Istio injection enabled
- Both namespaces have Istio injection enabled

## Install the Banzai Cloud istio-operator with the Backyards CLI

First of all, we need to install the [Backyards CLI](https://github.com/banzaicloud/backyards-cli) first:

```bash
curl https://getbackyards.sh | sh
```

Then install the `istio-operator` with it (we need only that this time):

```bash
backyards install
? Install istio-operator (recommended). Press enter to accept Yes
? Install canary-operator (recommended). Press enter to accept No
? Install and run demo application (optional). Press enter to skip No
```

Make sure you have [mTLS](https://istio.io/docs/tasks/security/authentication/authn-policy/#globally-enabling-istio-mutual-tls) enabled in the Istio mesh through the operator with the following command:

Enable it if not `STRICT`:

> With `kubectl`:
```bash
kubectl patch istio -n istio-system mesh --type=json -p='[{"op": "replace", "path": "/spec/mtls", "value":true}]'
```

> With `backyards`:
```bash
❯ backyards mtls require mesh
INFO[0000] switched global mTLS to STRICT successfully
```

After this, we can check that `istio-operator` has created a `default` [MeshPolicy](https://istio.io/docs/tasks/security/authentication/authn-policy/#globally-enabling-istio-mutual-tls) with `mTLS` turned on which applies to all applications in the cluster in Istio enabled namespaces. You can change this if you would like to use another policy.

> With `kubectl`:
```bash
$ kubectl get meshpolicy default -o yaml
apiVersion: authentication.istio.io/v1alpha1
kind: MeshPolicy
metadata:
  name: default
  labels:
    app: security
spec:
  peers:
  - mtls: {}
```

> With `backyards`:
```bash
$ backyards mtls get mesh
mTLS rule for /mesh

Policy    Targets  MtlsMode  
/default  []       STRICT
```

Now our cluster is properly running on Istio with mTLS enabled globally.

## Install the Bank-Vaults components

It is advised to create a separate namespace for Bank-Vaults called `vault-system`. Istio sidecar injection can be enabled here as well but Kubernetes won't be able to call back the webhook properly since mTLS is enabled (and Kubernetes is outside of the Istio mesh). To overcome this a `PERMISSIVE` Istio authentication policy has to be applied to the `vault-secrets-webhook` Service itself, so Kubernetes can call it back without Istio mutual TLS authentication:

```bash
kubectl create namespace vault-system
kubectl label namespace vault-system name=vault-system istio-injection=enabled
```

> With `kubectl`:
```bash
$ kubectl apply -f - <<EOF
apiVersion: authentication.istio.io/v1alpha1
kind: Policy
metadata:
  name: vault-secrets-webhook
  namespace: vault-system
  labels:
    app: security
spec:
  targets:
  - name: vault-secrets-webhook
  peers:
  - mtls:
      mode: PERMISSIVE
EOF
```

> With `backyards`:
$ backyards mtls allow vault-system/vault-secrets-webhook
INFO[0001] policy peers for vault-system/vault-secrets-webhook set successfully

mTLS rule for vault-system/vault-secrets-webhook

Policy                                    Targets                  MtlsMode
vault-system/vault-secrets-webhook-rw6mc  [vault-secrets-webhook]  PERMISSIVE
```

Now you can install the operator and the webhook to the prepared namespace:

```bash
helm repo add banzaicloud-stable https://kubernetes-charts.banzaicloud.com
helm upgrade --install vault-secrets-webhook banzaicloud-stable/vault-secrets-webhook --namespace vault-system
helm upgrade --install vault-operator banzaicloud-stable/vault-operator --namespace vault-system
```

Soon the webhook and the operator become up and running, you can check that the `istio-proxy` got injected into all Pods in `vault-infra`.

## Install Vault without Istio first

We can provision a Vault instance with the operator in a separate namespace:

```bash
kubectl create namespace vault
```

Apply the [RBAC](rbac.yaml) and [CR](cr-istio.yaml) files to the cluster to create a Vault instance in the `vault` namespace with the operator:

```bash
kubectl apply -f rbac.yaml -f cr-istio.yaml
```

```bash
$ kubectl get pods -n vault
NAME                               READY   STATUS    RESTARTS   AGE
vault-0                            3/3     Running   0          22h
vault-configurer-6458cc4bf-6tpkz   1/1     Running   0          22h
```

If you are writing your own Vault CR make sure that `istioEnabled: true` is configured, this influences port naming so the Vault service port protocols are detected by Istio correctly.

There is only one limitation, the `vault-secrets-webhook` can't inject Vault secrets into `initContainers` in an Istio enabled namespace, when the `STRICT` authentication policy is applied to the Vault service, because Istio needs a sidecar container to do mTLS properly, and in the phane when `initContainers` are running the Pod doesn't have a sidecar yet. If you wish to inject into `initContainers` as well, you need to apply a `PERMISSIVE` authentication policy in the `vault` namespace, since it has its own TLS certificate outside of Istio scope (so this is safe to do from networking security point of view).

> With `kubectl`:
```bash
$ kubectl apply -f - <<EOF
apiVersion: authentication.istio.io/v1alpha1
kind: Policy
metadata:
  name: default
  namespace: vault
  labels:
    app: security
spec:
  peers:
  - mtls:
      mode: PERMISSIVE
EOF
```

> With `backyards`:
```bash
$ backyards mtls allow vault
INFO[0001] policy peers for vault/ set successfully

mTLS rule for vault/

Policy         Targets  MtlsMode
vault/default  []       PERMISSIVE
```

## Install the application with Istio enabled

In this scenario Vault, itself is running without Istio and our demo application runs with Istio.

Create a namespace first for the application and enable Istio sidecar injection:

```bash
kubectl create namespace app
```

> With `kubectl`:
```bash
kubectl label namespace app istio-injection=enabled
```

> With `backyards`:
```bash
backyards sidecar-proxy auto-inject on app
```

Install the application [manifest](app.yaml) to the cluster:

```bash
kubectl apply -f app.yaml
```

Check that the application is up and running, it should have two containers, the `app` itself and the `istio-proxy`:

```bash
$ kubectl get pods -n app
NAME                  READY   STATUS    RESTARTS   AGE
app-5df5686c4-sl6dz   2/2     Running   0          119s
```

```bash
$ kubectl logs -f -n app deployment/app app
time="2020-02-18T14:26:01Z" level=info msg="Received new Vault token"
time="2020-02-18T14:26:01Z" level=info msg="Initial Vault token arrived"
s3cr3t
going to sleep...
```

## Enable Istio for Vault only

Turn off Istio in the `app` namespace by removing the `istio-injection` label:

> With `kubectl`:
```bash
kubectl label namespace app istio-injection-
kubectl label namespace vault istio-injection=enabled
```

> With `backyards`:
```bash
backyards sidecar-proxy auto-inject off app
backyards sidecar-proxy auto-inject on vault
```

Delete the Vault pods in the `vault` namespace, so they will get recreated with the `istio-proxy` sidecar:

```bash
kubectl delete pods --all -n vault
```

Check that they both come back with an extra container (4/4 and 2/2 now):

```
$ kubectl get pods -n vault
NAME                                READY   STATUS    RESTARTS   AGE
vault-0                             4/4     Running   0          1m
vault-configurer-6d9b98c856-l4flc   2/2     Running   0          1m
```

Delete the application pod in the `app` namespace, so they will get recreated without the `istio-proxy` sidecar:

```bash
kubectl delete pods --all -n app
```

The app pod got recreated with only the `app` container (1/1) and Vault access still works:

```bash
$ kubectl get pods -n app
NAME                  READY   STATUS    RESTARTS   AGE
app-5df5686c4-4n6r7   1/1     Running   0          71s

$ kubectl logs -f -n app deployment/app
time="2020-02-18T14:41:20Z" level=info msg="Received new Vault token"
time="2020-02-18T14:41:20Z" level=info msg="Initial Vault token arrived"
s3cr3t
going to sleep...
```

## Enable Istio at both sides

> With `kubectl`:
```bash
kubectl label namespace app   istio-injection=enabled
kubectl label namespace vault istio-injection=enabled
```

> With `backyards`:
```bash
backyards sidecar-proxy auto-inject on app
backyards sidecar-proxy auto-inject on vault
```

Delete all pods so they are getting injected with the proxy:

```bash
kubectl delete pods --all -n app
kubectl delete pods --all -n vault
```

Checking the logs in the app container should sill show success:

```bash
$ kubectl logs -f -n app deployment/app
time="2020-02-18T15:04:03Z" level=info msg="Initial Vault token arrived"
time="2020-02-18T15:04:03Z" level=info msg="Renewed Vault Token"
s3cr3t
going to sleep...
```
