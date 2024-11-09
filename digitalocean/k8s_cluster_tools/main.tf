terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }
}

variable "cluster_name" {
  description = "The name of the DigitalOcean cluster to configure"
  type        = string
  validation {
    condition     = length(var.cluster_name) > 0
    error_message = "A cluster name must be set"
  }
}

variable "enable_metrics" {
  description = "Enable metrics for the cluster"
  type        = bool
  default     = false
}

variable "load_balancer_hostname" {
  type        = string
  description = "The hostname to use for the load balancer created by nginx ingress"
}
data "digitalocean_kubernetes_cluster" "primary" {
  name = var.cluster_name
}

provider "kubernetes" {
  host  = data.digitalocean_kubernetes_cluster.primary.endpoint
  token = data.digitalocean_kubernetes_cluster.primary.kube_config[0].token
  cluster_ca_certificate = base64decode(
    data.digitalocean_kubernetes_cluster.primary.kube_config[0].cluster_ca_certificate
  )
}

provider "helm" {
  kubernetes {
    host  = data.digitalocean_kubernetes_cluster.primary.endpoint
    token = data.digitalocean_kubernetes_cluster.primary.kube_config[0].token
    cluster_ca_certificate = base64decode(
      data.digitalocean_kubernetes_cluster.primary.kube_config[0].cluster_ca_certificate
    )
  }
}

module "ingress_controller" {
  source                 = "../../k8s/ingress-controller-nginx"
  digitalocean           = true
  custom_error_pages     = true
  enable_metrics         = var.enable_metrics
  load_balancer_hostname = var.load_balancer_hostname
}

output "load_balancer_ip" {
  value = module.ingress_controller.load_balancer_ip
}
