---
---

The webhook checks if a container has environment variables defined in the following formats, and reads the values for those variables directly from Vault during startup time.

```yaml
        env:
        - name: AWS_SECRET_ACCESS_KEY
          value: vault:secret/data/accounts/aws#AWS_SECRET_ACCESS_KEY
# or
        - name: AWS_SECRET_ACCESS_KEY
          valueFrom:
            secretKeyRef:
              name: aws-key-secret
              key: AWS_SECRET_ACCESS_KEY
# or
        - name: AWS_SECRET_ACCESS_KEY
            valueFrom:
              configMapKeyRef:
                name: aws-key-configmap
                key: AWS_SECRET_ACCESS_KEY
```

The webhook checks if a container has *envFrom* and parses the defined ConfigMaps and Secrets:

```yaml
        envFrom:
          - secretRef:
              name: aws-key-secret
# or
          - configMapRef:
              name: aws-key-configmap
```

## Secret and ConfigMap examples

Secrets require their payload to be base64 encoded, the API rejects manifests with plaintext in them.
The secret value should contain a base64 encoded template string referencing the vault path you want to insert.
Run `echo -n "vault:secret/data/accounts/aws#AWS_SECRET_ACCESS_KEY" | base64` to get the correct string.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: aws-key-secret
data:
  AWS_SECRET_ACCESS_KEY: dmF1bHQ6c2VjcmV0L2RhdGEvYWNjb3VudHMvYXdzI0FXU19TRUNSRVRfQUNDRVNTX0tFWQ==
type: Opaque
```

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-key-configmap
data:
  AWS_SECRET_ACCESSKEY: vault:secret/data/accounts/aws#AWS_SECRET_ACCESS_KEY
```
