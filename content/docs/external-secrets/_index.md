---
title: Watching External Secrets
linktitle: External Secrets
weight: 1100
---

In some cases, you might have to restart the Vault StatefulSet when secrets that are not managed by the operator control are changed. For example:

- Cert-Manager managing a public Certificate for vault using Let's Encrypt.
- Cloud IAM Credentials created with an external tool (like terraform) to allow vault to interact with the cloud services.

The operator can watch a set of secrets in the namespace of the Vault resource using either a list of label selectors or an annotations selector. When the content of any of those secrets changes, the operator updates the StatefulSet and triggers a rolling restart.

## Configure label selectors

Set the secrets to watch using the **watchedSecretsAnnotations** and **watchedSecretsLabels** fields in your Vault custom resource.

> Note: For cert-manager 0.11 or newer, use the `watchedSecretsAnnotations` field.

In the following example, the Vault StatefulSet is restarted when:

- A secret with label _certmanager.k8s.io/certificate-name: vault-letsencrypt-cert_ changes its contents (cert-manager 0.10 and earlier).
- A secret with label _test.com/scope: gcp_ AND _test.com/credentials: vault_ changes its contents.
- A secret with annotation _cert-manager.io/certificate-name: vault-letsencrypt-cert_ changes its contents (cert-manager 0.11 and newer).

```yaml
watchedSecretsLabels:
  - certmanager.k8s.io/certificate-name: vault-letsencrypt-cert
  - test.com/scope: gcp
    test.com/credentials: vault

watchedSecretsAnnotations:
  - cert-manager.io/certificate-name: vault-letsencrypt-cert
```

The operator controls the restart of the StatefulSet by adding an _annotation_ to the _spec.template_ of the vault resource

```bash
kubectl get -n vault statefulset vault -o json | jq .spec.template.metadata.annotations
{
  "prometheus.io/path": "/metrics",
  "prometheus.io/port": "9102",
  "prometheus.io/scrape": "true",
  "vault.banzaicloud.io/watched-secrets-sum": "ff1f1c79a31f76c68097975977746be9b85878f4737b8ee5a9d6ee3c5169b0ba"
}
```
