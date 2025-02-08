terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source = "hashicorp/helm"
    }
    random = {
      source = "hashicorp/random"
    }
    rancher2 = {
      source = "rancher/rancher2"
    }
  }
}

# Configure the Rancher2 provider to bootstrap the installation
provider "rancher2" {
  api_url   = local.server_url
  bootstrap = true
  # On creation it might take a while to be ready
  timeout = "5m"
  # Usually true only in tests
  insecure = var.self_signed
}
