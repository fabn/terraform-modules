terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source = "hashicorp/helm"
    }
    # Needed for default issuer
    kubectl = {
      source = "alekc/kubectl"
    }
  }
}
