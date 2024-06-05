resource "helm_release" "prometheus" {
  name             = "prometheus"
  chart            = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  namespace        = "prometheus"
  create_namespace = true

  version = "45.8.0"

  set {
    name  = "fullnameOverride"
    value = "prometheus"
  }

  values = [
    "${file("./helm/prometheus/values.yml")}"
  ]


  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.cluster,
    kubernetes_config_map.aws-auth
  ]
}

resource "kubectl_manifest" "grafana_ingress" {
  yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana-ingress
  namespace: prometheus
spec:
  ingressClassName: cilium
  rules:
  - host: ${var.grafana_host}
    http:
      paths:
      - backend:
          service:
            name: prometheus-grafana
            port:
              number: 80
        path: /
        pathType: Prefix
YAML

  depends_on = [
    helm_release.prometheus
  ]

}


resource "kubernetes_secret" "prometheus_scrape_configs" {
  metadata {
    name        = "additional-scrape-configs"
    namespace   = "prometheus"
  }

  data = {
    "scrape_configs.yaml" = "${file("${path.module}/helm/prometheus/scrape_configs.yml")}"
  }

  type = "Opaque"

  depends_on = [
    helm_release.prometheus
  ]
}



resource "kubectl_manifest" "prometheus_all_pod_monitor" {

    count = 0

  yaml_body = <<YAML
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: generic-stats-monitor
  namespace: prometheus
  labels:
    monitoring: istio-proxies
    release: istio
spec:
  selector:
    matchExpressions:
    - {key: istio-prometheus-ignore, operator: DoesNotExist}
  namespaceSelector:
    any: true
  jobLabel: generic-stats
  podMetricsEndpoints:
  - path: /metrics
    interval: 15s
    relabelings:
    - action: keep
YAML

  depends_on = [
    helm_release.prometheus
  ]

}