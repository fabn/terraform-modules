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

resource "kubernetes_namespace_v1" "ns" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret_v1" "api_key" {
  metadata {
    name      = "datadog-api-key"
    namespace = kubernetes_namespace_v1.ns.metadata.0.name
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
  namespace  = kubernetes_namespace_v1.ns.metadata.0.name
  atomic     = true
  # Static values and values that need to be templated
  values = compact([
    # Additional extra values to pass to the chart
    var.extra_values != null ? yamlencode(var.extra_values) : null,
    # Additional values as raw yaml
    var.extra_yaml != null ? var.extra_yaml : null,
  ])
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

# @see https://github.com/DataDog/datadog-operator/blob/main/examples/datadogagent/datadog-agent-all.yaml
# @see https://github.com/DataDog/datadog-operator/blob/main/docs/configuration.v2alpha1.md
resource "kubectl_manifest" "agent" {
  depends_on = [helm_release.datadog_operator]
  yaml_body = yamlencode({
    apiVersion = "datadoghq.com/v2alpha1",
    kind       = "DatadogAgent",
    metadata = {
      name      = "datadog"
      namespace = kubernetes_namespace_v1.ns.metadata.0.name
    },
    spec = {
      global = {
        clusterName = var.cluster_name,
        site        = var.dd_site,
        tags        = [for k, v in var.global_tags : "${k}:${v}"]
        credentials = {
          apiSecret = {
            secretName = kubernetes_secret_v1.api_key.metadata.0.name,
            keyName    = "api_key"
          }
        }
      }
      # Opt in flags for features
      features = merge({
        # Enable the agent to collect logs by var
        logCollection = {
          enabled             = var.logging_enabled
          containerCollectAll = var.collect_all_logging
        }
        },
        # User supplied features
        var.features_override
      )

      # Discovery options
      override = {
        # This will be passed to the datadog agent CRD and will impact datadog-agent DaemonSet
        nodeAgent = merge({ env = local.agent_env }, var.datadog_agent_overrides)
        # This will be passed to the datadog agent CRD and will impact datadog-agent Deployment
        clusterAgent = var.cluster_agent_overrides
      }
    }
  })
}
