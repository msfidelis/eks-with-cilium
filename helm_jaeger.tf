resource "helm_release" "jaeger" {
    name                = "jaeger"
    repository          = "https://jaegertracing.github.io/helm-charts" 
    chart               = "jaeger"
    namespace           = "jaeger"

    version             = "0.71.10"

    create_namespace    = true

    depends_on = [
        aws_eks_cluster.eks_cluster,
        aws_eks_node_group.cluster,
        kubernetes_config_map.aws-auth
    ]
}

resource "kubectl_manifest" "jaeger_ingress" {
  yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: jaeger-ingress
  namespace: jaeger
spec:
  ingressClassName: cilium
  rules:
  - host: ${var.jaeger_host}
    http:
      paths:
      - backend:
          service:
            name: jaeger-query
            port:
              number: 80
        path: /
        pathType: Prefix
YAML

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.cluster,
    kubernetes_config_map.aws-auth,
    helm_release.jaeger,
  ]

}
