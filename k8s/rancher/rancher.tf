# bootstrap and admin password
resource "random_password" "bootstrap" {
  count  = var.bootstrap_password == null ? 1 : 0
  length = 20
  # Some chars might break values output when parsed as yaml
  special = false
}

locals {
  bootstrap_password = var.bootstrap_password != null ? var.bootstrap_password : random_password.bootstrap[0].result
  # Final server url, always in https
  server_url = "https://${var.hostname}"

  # # https://ranchermanager.docs.rancher.com/how-to-guides/advanced-user-guides/monitoring-alerting-guides/enable-monitoring#enabling-the-rancher-performance-dashboard
  performance_dashboard = {
    extraEnv = [
      {
        name  = "CATTLE_PROMETHEUS_METRICS"
        value = "true"
      }
    ]
  }

}
resource "kubernetes_namespace_v1" "ns" {
  count = var.create_namespace ? 1 : 0
  metadata {
    name = var.namespace
  }
  # Used mainly in test to allow the namespace to be destroyed
  provisioner "local-exec" {
    # Use the rancher cleanup tool to remove all resources
    # see https://github.com/rancher/rancher-cleanup
    when    = destroy
    command = <<-EOT
    kubectl apply -f https://raw.githubusercontent.com/rancher/rancher-cleanup/refs/heads/main/deploy/rancher-cleanup.yaml
    EOT
  }
}

locals {

  # If letsencrypt is enabled we need to pass some settings
  tls_values = {
    ingress = {
      tls = { source = "letsEncrypt" }
    }
    letsEncrypt = {
      email       = var.letsencrypt.email
      environment = coalesce(var.letsencrypt.environment, "production")
    }
  }

  base_values = {
    hostname          = var.hostname
    bootstrapPassword = local.bootstrap_password
    # Can be ingress or external, default is ingress but it requires cert
    # manager to be installed, since it declare an Issuer
    tls      = !var.letsencrypt.enabled && var.self_signed ? "external" : "ingress"
    replicas = var.replicas
  }

  final_values = merge(
    local.base_values,
    var.ingress_class_name != null ? { "ingress.ingressClassName" = var.ingress_class_name } : {}
  )
}

resource "helm_release" "rancher" {
  name              = var.release_name
  chart             = "rancher"
  version           = var.chart_version
  namespace         = kubernetes_namespace_v1.ns[0].metadata.0.name
  repository        = "https://releases.rancher.com/server-charts/stable"
  lint              = true              # Useful to detect errors during plan
  timeout           = 900               # First boot of rancher can take a while
  disable_webhooks  = var.disable_hooks # Some hook fails in CI so disable them
  disable_crd_hooks = var.disable_hooks # Some hook fails in CI so disable them

  set = [for k, v in local.final_values : { name = k, value = tostring(v) }]

  # List of YAML templates to merge
  values = compact([
    var.enable_performance_dashboard ? yamlencode(local.performance_dashboard) : null,
    # Let's encrypt settings
    var.letsencrypt.enabled ? yamlencode(local.tls_values) : null,
    # Additional extra values to pass to the chart
    var.extra_values != null ? yamlencode(var.extra_values) : null,
  ])
}
