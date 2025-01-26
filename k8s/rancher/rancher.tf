# bootstrap and admin password
resource "random_password" "bootstrap" {
  count  = var.bootstrap_password == null ? 1 : 0
  length = 16
}

resource "random_password" "admin" {
  count  = var.admin_password == null ? 1 : 0
  length = 16
}

locals {
  bootstrap_password = var.bootstrap_password != null ? var.bootstrap_password : random_password.bootstrap[0].result
  admin_password     = var.admin_password != null ? var.admin_password : random_password.admin[0].result

  has_tls = false

  # Final server url, always in https
  server_url = "https://${var.hostname}"


  # # https://ranchermanager.docs.rancher.com/how-to-guides/advanced-user-guides/monitoring-alerting-guides/enable-monitoring#enabling-the-rancher-performance-dashboard
  performance_dashboard = yamlencode({
    extraEnv = [
      {
        name  = "CATTLE_PROMETHEUS_METRICS"
        value = "true"
      }
    ]
  })

}
resource "kubernetes_namespace_v1" "ns" {
  count = var.create_namespace ? 1 : 0
  metadata {
    name = var.namespace
  }
  # Used mainly in test to allow the namespace to be destroyed
  provisioner "local-exec" {
    when = destroy
    # See https://stackoverflow.com/a/52820472/518204
    command = <<-EOT
    kubectl patch ns ${self.metadata[0].name} -p '{"metadata":{"finalizers":null}}' --type=merge
    EOT
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

  # List of YAML templates to merge
  values = compact([
    local.performance_dashboard,
    # Additional extra values to pass to the chart
    var.extra_values != null ? yamlencode(var.extra_values) : null,
  ])

  set {
    name  = "hostname"
    value = var.hostname
  }

  set {
    name  = "bootstrapPassword"
    value = local.bootstrap_password
  }

  # Can be ingress or external, default is ingress but it requires cert
  # manager to be installed, since it declare an Issuer
  set {
    name  = "tls"
    value = var.self_signed ? "external" : "ingress"
  }

  set {
    name  = "replicas"
    value = var.replicas
  }

  # Optionally sets a specific ingress class name
  dynamic "set" {
    for_each = var.ingress_class_name != null ? [1] : []
    content {
      name  = "ingress.ingressClassName"
      value = var.ingress_class_name
    }
  }
}

# Bootstrap the rancher installation
resource "rancher2_bootstrap" "admin" {
  # Used to bootstrap the rancher installation
  initial_password = local.bootstrap_password
  # Will be kept in sync for the admin user
  password = local.admin_password
  # Don't send telemetry data
  telemetry = false
  # By default generate a token that doesn't expire
  token_ttl = 0
}


# Values to integrate:
# ingress.tls.source
# letsEncrypt.email
# letsEncrypt.environment
