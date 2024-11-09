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
  source = "../k8s_cluster"
  name   = var.cluster_name
  region = "fra1"
}
