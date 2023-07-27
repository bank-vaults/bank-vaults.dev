---
---
```bash
kubectl kustomize https://github.com/bank-vaults/vault-operator/deploy/rbac | kubectl apply -f -
```

Expected output:

```bash
serviceaccount/vault created
role.rbac.authorization.k8s.io/vault created
role.rbac.authorization.k8s.io/leader-election-role created
rolebinding.rbac.authorization.k8s.io/leader-election-rolebinding created
rolebinding.rbac.authorization.k8s.io/vault created
clusterrolebinding.rbac.authorization.k8s.io/vault-auth-delegator created
```
