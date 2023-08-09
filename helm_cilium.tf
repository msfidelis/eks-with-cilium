
resource "helm_release" "cilium" {
  name       = "cilium"
  chart      = "cilium"
  repository = "https://helm.cilium.io/"
  namespace  = "kube-system"

  create_namespace = true

  version = "1.14"

  set {
    name  = "eni.enabled"
    value = true
  }

  set {
    name  = "ipam.mode"
    value = "eni"
  }

  set {
    name  = "egressMasqueradeInterfaces"
    value = "eth0"
  }

  set {
    name  = "routingMode"
    value = "native"
  }

  set {
    name  = "kubeProxyReplacement"
    value = "strict"
  }

  set {
    name  = "externalIPs.enabled"
    value = true
  }

  set {
    name  = "nodePort.enabled"
    value = true
  }

  set {
    name  = "hostPort.enabled"
    value = true
  }

  set {
    name  = "hostServices.enabled"
    value = true
  }


  set {
    name  = "bpf.masquerade"
    value = false
  }

  set {
    name  = "ingressController.enabled"
    value = true
  }

  set {
    name  = "ingressController.service.type"
    value = "NodePort"
  }

  set {
    name  = "ingressController.service.insecureNodePort"
    value = "30080"
  }

  set {
    name  = "ingressController.service.secureNodePort"
    value = "30443"
  }

  set {
    name  = "ingressController.loadbalancerMode"
    value = "shared"
  }

  set {
    name  = "hubble.relay.enabled"
    value = true
  }

  set {
    name  = "hubble.ui.enabled"
    value = true
  }

  set {
    name  = "hubble.prometheus.enabled"
    value = true
  }

  set {
    name  = "hubble.metrics.serviceMonitor.enabled"
    value = true
  }

  set {
    name  = "hubble.metrics.enableOpenMetrics"
    value = true
  }

  set {
    name  = "hubble.metrics.enabled"
    value = "{dns,drop,tcp,flow,port-distribution,icmp,httpV2:exemplars=true;labelsContext=source_ip\\,source_namespace\\,source_workload\\,destination_ip\\,destination_namespace\\,destination_workload\\,traffic_direction}"
  }

  set {
    name  = "prometheus.enabled"
    value = true
  }

  set {
    name  = "prometheus.serviceMonitor.enabled"
    value = true
  }

  set {
    name  = "operator.prometheus.enabled"
    value = true
  }

  #   set {
  #     name  = "extraConfig.enable-envoy-config"
  #     value = "true"
  #   }

  set {
    name  = "loadBalancer.l7.backend"
    value = "envoy"
  }

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.cluster,
    kubernetes_config_map.aws-auth
  ]
}

resource "helm_release" "tetragon" {
  name       = "tetragon"
  chart      = "tetragon"
  repository = "https://helm.cilium.io/"
  namespace  = "kube-system"

  create_namespace = true

  version = "0.10.0"

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.cluster,
    kubernetes_config_map.aws-auth,
    helm_release.cilium,
  ]
}

resource "kubectl_manifest" "cilium_target_group_binding_http" {
  yaml_body = <<YAML
apiVersion: elbv2.k8s.aws/v1beta1
kind: TargetGroupBinding
metadata:
  name: cilium-ingress
  namespace: kube-system
spec:
  serviceRef:
    name: cilium-ingress
    port: http
  targetGroupARN: ${aws_lb_target_group.http.arn}
YAML


  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.cluster,
    kubernetes_config_map.aws-auth,
    helm_release.cilium,
  ]

}

resource "kubectl_manifest" "cilium_target_group_binding_https" {
  yaml_body = <<YAML
apiVersion: elbv2.k8s.aws/v1beta1
kind: TargetGroupBinding
metadata:
  name: cilium-ingress-https
  namespace: kube-system
spec:
  serviceRef:
    name: cilium-ingress
    port: https
  targetGroupARN: ${aws_lb_target_group.https.arn}
YAML

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.cluster,
    kubernetes_config_map.aws-auth,
    helm_release.cilium,
  ]

}


resource "kubectl_manifest" "hubble_ingress" {
  yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hubble-ingress
  namespace: kube-system
spec:
  ingressClassName: cilium
  rules:
  - host: ${var.cilium_hubble_host}
    http:
      paths:
      - backend:
          service:
            name: hubble-ui
            port:
              number: 80
        path: /
        pathType: Prefix
YAML

  depends_on = [
    aws_eks_cluster.eks_cluster,
    aws_eks_node_group.cluster,
    kubernetes_config_map.aws-auth,
    helm_release.cilium,
  ]

}
