# bootstrap password
resource "random_password" "admin" {
  count  = var.bootstrap_password == null ? 1 : 0
  length = 10
}

locals {
  bootstrap_password = var.bootstrap_password != null ? var.bootstrap_password : random_password.admin[0].result
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

  set {
    name  = "hostname"
    value = var.hostname
  }

  set {
    name  = "bootstrapPassword"
    value = local.bootstrap_password
  }

  set {
    name  = "ingress.tls.source"
    value = "rancher" # disable letsencrypt
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
