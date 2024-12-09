module "prometheus" {
  source = "../has-crd"
  name   = "servicemonitors.monitoring.coreos.com"
}

data "kubernetes_namespace_v1" "ns" {
  metadata {
    name = var.namespace
  }
}

# Input variable passed to module
resource "helm_release" "metrics_server" {
  name             = var.release_name
  chart            = "metrics-server"
  version          = var.chart_version
  namespace        = var.namespace
  repository       = "https://kubernetes-sigs.github.io/metrics-server/"
  create_namespace = data.kubernetes_namespace_v1.ns.spec == null
  atomic           = true
  lint             = true # Useful to detect errors during plan

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
    value = module.prometheus.has_crd
  }

  # Need prometheus to be installed first
  set {
    name  = "serviceMonitor.enabled"
    value = module.prometheus.has_crd
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
