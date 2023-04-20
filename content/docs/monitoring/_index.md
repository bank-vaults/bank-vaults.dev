---
title: Monitoring
weight: 900
---

At Banzai Cloud we prefer Prometheus for monitoring and use it also for Vault. If you configure, Vault can expose metrics through [statsd](https://www.vaultproject.io/docs/configuration/telemetry.html#statsd). Both the [Helm chart](https://github.com/banzaicloud/bank-vaults/tree/master/charts/vault) and the Vault Operator installs the [Prometheus StatsD exporter](https://github.com/prometheus/statsd_exporter) and annotates the pods correctly with Prometheus annotations so Prometheus can discover and scrape them. All you have to do is to put the telemetry stanza into your Vault configuration:

```yaml
    telemetry:
      statsd_address: localhost:9125
```

You may find the [generic Prometheus kubernetes client Go Process runtime monitoring dashboard](https://grafana.com/grafana/dashboards/240) useful for monitoring the webhook or any other Go process.

To monitor the [mutating webhook](/docs/mutating-webhook/), see {{% xref "/docs/mutating-webhook/monitoring.md" %}}.
