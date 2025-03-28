locals {
  namespace = var.create_namespace ? kubernetes_namespace_v1.ns[0].metadata[0].name : var.namespace
}

resource "kubernetes_namespace_v1" "ns" {
  count = var.create_namespace ? 1 : 0
  metadata {
    name = var.namespace
  }
}

# Input variable passed to module
resource "helm_release" "metrics_server" {
  name       = var.release_name
  chart      = "metrics-server"
  version    = var.chart_version
  namespace  = local.namespace
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  atomic     = true
  lint       = true # Useful to detect errors during plan

  # Not working as plain set, since it's an object
  values = [
    templatefile("${path.module}/metrics-server-limits.yml", {
      cpu_requests    = var.resources.requests.cpu
      memory_requests = var.resources.requests.memory
      memory_limits   = var.resources.limits.memory
    })
  ]

  set {
    name  = "metrics.enabled"
    value = var.metrics_enabled
  }

  # Need prometheus to be installed first
  set {
    name  = "serviceMonitor.enabled"
    value = var.service_monitor_enabled
  }

  # When running in kind this is needed to avoid TLS errors
  dynamic "set_list" {
    for_each = var.kind ? [1] : []
    content {
      name  = "args"
      value = ["--kubelet-insecure-tls"]
    }
  }
}
