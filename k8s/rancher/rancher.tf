# bootstrap password
resource "random_password" "admin" {
  count  = var.bootstrap_password == null ? 1 : 0
  length = 10
}

locals {
  bootstrap_password = var.bootstrap_password != null ? var.bootstrap_password : random_password.admin[0].result

  has_tls = false

  # Final server url
  server_url = "${local.has_tls ? "https" : "http"}://${var.hostname}"
}
resource "kubernetes_namespace_v1" "ns" {
  count = var.create_namespace ? 1 : 0
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "rancher" {
  name       = var.release_name
  chart      = "rancher"
  version    = var.chart_version
  namespace  = kubernetes_namespace_v1.ns[0].metadata.0.name
  repository = "https://releases.rancher.com/server-charts/stable"
  lint       = true # Useful to detect errors during plan
  timeout    = 900  # First boot of rancher can take a while

  set {
    name  = "hostname"
    value = var.hostname
  }

  set {
    name  = "bootstrapPassword"
    value = local.bootstrap_password
  }

  # Can be ingress or external, default is ingress but it requires cert manager to work
  set {
    name  = "tls"
    value = local.has_tls ? "ingress" : "external"
  }

  set {
    name  = "replicas"
    value = var.replicas
  }
}


# # https://ranchermanager.docs.rancher.com/how-to-guides/advanced-user-guides/monitoring-alerting-guides/enable-monitoring#enabling-the-rancher-performance-dashboard
# extraEnv:
#   - name: "CATTLE_PROMETHEUS_METRICS"
#     value: "true"

# Values to integrate:
# ingress.tls.source
# letsEncrypt.email
# letsEncrypt.environment
