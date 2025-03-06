terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    helm = {
      source = "hashicorp/helm"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.1.3"
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

resource "helm_release" "datadog_operator" {
  name       = "datadog-operator"
  chart      = "datadog-operator"
  repository = "https://helm.datadoghq.com"
  version    = var.chart_version
  namespace  = kubernetes_namespace.ns.metadata.0.name
  atomic     = true
}

resource "kubectl_manifest" "agent" {
  yaml_body = yamlencode({
    apiVersion = "datadoghq.com/v2alpha1",
    kind       = "DatadogAgent",
    metadata = {
      name      = "datadog"
      namespace = kubernetes_namespace.ns.metadata.0.name
    },
    spec = {
      global = {
        clusterName = var.cluster_name,
        site        = var.dd_site,
        credentials = {
          apiSecret = {
            secretName = kubernetes_secret.api_key.metadata.0.name,
            keyName    = "api_key"
          }
        }
      }
    }
  })
}
