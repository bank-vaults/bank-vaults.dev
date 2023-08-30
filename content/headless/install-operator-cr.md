---
---
```bash
kubectl apply -f https://raw.githubusercontent.com/bank-vaults/vault-operator/v{{< param "latest_operator_version" >}}/deploy/examples/cr-raft.yaml
```

Expected output:

```bash
vault.vault.banzaicloud.com/vault created
```

> Note: If needed, you can install the latest CustomResource from the main branch, but that's usually under development and might not be stable.
>
> ```bash
> kubectl apply -f https://raw.githubusercontent.com/bank-vaults/vault-operator/main/deploy/examples/cr-raft.yaml
> ```
