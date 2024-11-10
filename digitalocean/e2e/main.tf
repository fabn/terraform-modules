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


provider "kubernetes" {
  host  = module.e2e_cluster.cluster.endpoint
  token = module.e2e_cluster.cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(
    module.e2e_cluster.cluster.kube_config[0].cluster_ca_certificate
  )
}

module "e2e_cluster" {
  source     = "../k8s_cluster"
  name       = var.cluster_name
  region     = "fra1"
  node_count = 1
  node_size  = null # In this way it will use the cheapest available
}

locals {
  # This is a quick and dirty hack to delay the tools module until the cluster is ready
  # Otherwise the tools module will fail because the cluster doesn't exist at plan time
  name = module.e2e_cluster.cluster.id ? module.e2e_cluster.cluster.name : var.cluster_name
}

module "tools" {
  source                 = "../k8s_cluster_tools"
  cluster_name           = local.name
  load_balancer_hostname = "${module.e2e_cluster.cluster.id}.fabn.dev"
}

output "ip" {
  value = module.tools.load_balancer_ip
}

output "base_domain" {
  value = module.tools.load_balancer_hostname
}
