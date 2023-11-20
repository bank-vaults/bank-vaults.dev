---
title: Monitoring
weight: 900
aliases:
- /docs/monitoring/
---

You can use Prometheus to monitor Vault. You can configure Vault to expose metrics through [statsd](https://developer.hashicorp.com/vault/docs/configuration/telemetry#statsd). Both the [Helm chart](https://github.com/bank-vaults/vault-helm-chart/tree/main/vault) and the [Vault Operator]({{< relref "/docs/installing/_index.md#deploy-operator" >}}) installs the [Prometheus StatsD exporter](https://github.com/prometheus/statsd_exporter) and annotates the pods correctly with Prometheus annotations so Prometheus can discover and scrape them. All you have to do is to put the telemetry stanza into your Vault configuration:

```yaml
    telemetry:
      statsd_address: localhost:9125
```

You may find the [generic Prometheus kubernetes client Go Process runtime monitoring dashboard](https://grafana.com/grafana/dashboards/240) useful for monitoring the webhook or any other Go process.

To monitor the [mutating webhook]({{< relref "/docs/mutating-webhook/_index.md" >}}), see {{% xref "/docs/mutating-webhook/monitoring.md" %}}.
