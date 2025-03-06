terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }
}

resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret" "api_key" {
  metadata {
    name      = "datadog-api-key"
    namespace = kubernetes_namespace.ns.metadata.0.name
  }

  data = {
    api_key = var.dd_api_key
  }
}
