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
  }
}

# Temporary check used as precondition in the module to ensure we're on kind
data "kubernetes_namespace_v1" "ns" {
  metadata {
    name = "local-path-storage"
  }
  lifecycle {
    postcondition {
      condition     = "local-path-storage" == self.metadata.0.name
      error_message = "Not ready for non kind clusters"
    }
  }
}
