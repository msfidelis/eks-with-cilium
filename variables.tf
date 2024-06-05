variable "cluster_name" {
  default = "eks-cilium"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "k8s_version" {
  default = "1.29"
}

variable "nodes_instances_sizes" {
  default = [
    "t3.large"
  ]
}

variable "auto_scale_options" {
  default = {
    min     = 4
    max     = 10
    desired = 6
  }
}

variable "nlb_ingress_internal" {
  type    = bool
  default = false
}

variable "nlb_ingress_type" {
  type    = string
  default = "network"
}

variable "proxy_protocol_v2" {
  type    = bool 
  default = false
}

variable "nlb_ingress_enable_termination_protection" {
  type    = bool
  default = false
}

variable "enable_cross_zone_load_balancing" {
  type    = bool
  default = false
}

variable "cluster_private_zone" {
  type    = string
  default = "k8s.cluster"
}

##################################
#        Cilium Configs          #
##################################

variable "cilium_hubble_host" {
  type    = string
  default = "hubble.msfidelis.com.br"
}

##################################
#        Pixie Configs          #
##################################

variable "cilium_hubble_host" {
  type    = string
  default = "pixie.msfidelis.com.br"
}

##################################
#        Jaeger Configs          #
##################################

variable "jaeger_host" {
  type    = string
  default = "jaeger.msfidelis.com.br"
}


##################################
#        Grafana Configs         #
##################################

variable "grafana_host" {
  type    = string
  default = "grafana.msfidelis.com.br"
}


##################################
#             ADDONS             #
##################################

variable "addon_cni_version" {
  type        = string
  description = "Specifies the version of the AWS VPC CNI (Container Network Interface) plugin to use, which manages the network interfaces for pod networking."
  default     = "v1.14.1-eksbuild.1"
}

variable "addon_coredns_version" {
  type        = string
  description = "Defines the version of CoreDNS to use, a DNS server/forwarder that is integral to internal Kubernetes DNS resolution."
  default     = "v1.11.1-eksbuild.4"
}

variable "addon_kubeproxy_version" {
  type        = string
  description = "Sets the version of Kubeproxy to be used, which handles Kubernetes network services like forwarding the requests to correct containers."
  default     = "v1.29.0-eksbuild.1"
}

variable "addon_csi_version" {
  type        = string
  description = "Indicates the version of the Container Storage Interface (CSI) driver to use for managing storage volumes in Kubernetes."
  default     = "v1.26.1-eksbuild.1"
}

##################################
#            TOGGLES             #
##################################

variable "chaos_mesh_toggle" {
  type        = bool
  description = "Enable Chaos Mesh Installation"
  default     = false
}

variable "argo_rollouts_toggle" {
  type        = bool
  description = "Enable Argo Rollouts Installation"
  default     = false
}

variable "keda_toggle" {
  type        = bool
  description = "Enable Keda Installation"
  default     = false
}

variable "cluster_autoscaler_toggle" {
  type        = bool
  description = "Enable Cluster Autoscaler Installation"
  default     = false
}

variable "descheduler_toggle" {
  type        = bool
  description = "Enable Descheduler Installation"
  default     = false
}

variable "jaeger_toggle" {
  type        = bool
  description = "Enable Jaeger Installation"
  default     = false
}

variable "default_tags" {
  default = {
    Environment = "prod"
    Foo         = "Bar"
    Ping        = "Pong"
  }
}