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

locals {
  excluded_namespaces = [for ns in coalesce(var.discovered_namespaces.excluded_namespaces, []) : "kube_namespace:${ns}"]
  included_namespaces = [for ns in coalesce(var.discovered_namespaces.included_namespaces, []) : "kube_namespace:${ns}"]

  # see https://docs.datadoghq.com/containers/guide/container-discovery-management/?tab=datadogoperator#environment-variables
  agent_env = [
    { name = "DD_CONTAINER_EXCLUDE", value = join(" ", local.excluded_namespaces) },
    { name = "DD_CONTAINER_INCLUDE", value = join(" ", local.included_namespaces) },
  ]
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
      # Opt in flags for features
      features = {
        logCollection = {
          enabled             = var.logging_enabled
          containerCollectAll = var.collect_all_logging
        }
      }
      # Discovery options
      override = {
        nodeAgent = {
          env = local.agent_env
        }
      }
    }
  })
}
