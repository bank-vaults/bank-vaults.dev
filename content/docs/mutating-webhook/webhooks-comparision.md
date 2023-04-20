---
title: Comparison of Banzai Cloud and HashiCorp mutating webhook for Vault
linktitle: Comparison
weight: 500
---

#### Legend

- &#9989;: Implemented
- o: Planned/In-progress

| Feature    | Banzai Cloud Webhook | HashiCorp Webhook |
|------------|----------------------|-------------------|
| Automated Vault and K8S setup | &#9989; (operator) |     |
| vault-agent/consul-template sidecar injection | &#9989; | &#9989; |
| Direct env var injection      | &#9989; |   |
| Injecting into K8S Secrets    | &#9989; |   |
| Injecting into K8S ConfigMaps | &#9989; |   |
| Injecting into K8S CRDs | &#9989; |   |
| Sidecar-less dynamic secrets  | &#9989; |   |
| CSI Driver                    | o |   |
| Native Kubernetes sidecar     | o |   |
