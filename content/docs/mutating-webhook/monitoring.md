---
title: Monitoring the Webhook with Grafana and Prometheus
shortTitle: Monitoring
weight: 300
---

To monitor the webhook with Prometheus and Grafana, complete the following steps.

## Prerequisites

- An already deployed and configured mutating webhook. For details, see {{% xref "/docs/mutating-webhook/_index.md" %}}.

## Steps

1. Install the Prometheus Operator Bundle:

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/master/bundle.yaml
    ```

1. Install the webhook with monitoring and Prometheus Operator ServiceMonitor enabled:

    ```bash
    helm upgrade --wait --install vault-secrets-webhook \
        banzaicloud-stable/vault-secrets-webhook \
        --namespace vault-infra \
        --set metrics.enabled=true \
        --set metrics.serviceMonitor.enabled={}
    ```

1. Create a Prometheus instance which monitors the components of Bank-Vaults:

    ```bash
    kubectl apply -f https://raw.githubusercontent.com/banzaicloud/bank-vaults/master/hack/prometheus.yaml
    ```

1. Create a Grafana instance and expose it:

    ```bash
    kubectl create deployment grafana --image grafana/grafana
    kubectl expose deployment grafana --port 3000 --type LoadBalancer
    ```

1. Fetch the external IP address of the Grafana instance, and open it in your browser on port 3000.

    ```bash
    kubectl get service grafana
    ```

1. [Create a Prometheus Data Source](https://prometheus.io/docs/visualization/grafana/#creating-a-prometheus-data-source) in this Grafana instance which grabs data from http://prometheus-operated:9090/.

1. [Import](https://prometheus.io/docs/visualization/grafana/#importing-pre-built-dashboards-from-grafana-com) the [Kubewebhook admission webhook dashboard](https://grafana.com/grafana/dashboards/7088) to Grafana (created by Xabier Larrakoetxea).

1. Select the previously created Data Source to feed this dashboard.
