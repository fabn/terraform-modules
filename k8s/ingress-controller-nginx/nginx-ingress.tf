# Deploy a sample service to demonstrate ingress is working
resource "kubernetes_namespace_v1" "namespace" {
  metadata {
    name = var.namespace
  }
}

output "debug" {
  value = local.resources_config
}

locals {
  ingress_class_name = var.default_ingress ? "nginx" : "nginx-${var.release_name}"

  resources_config = templatefile("${path.module}/resources.yml", {
    requests : var.resources.requests
    limits : var.resources.limits
  })

  autoscaling = {
    enabled                           = (coalesce(var.autoscale.enabled, true) && var.enable_metrics)
    minReplicas                       = coalesce(var.autoscale.minReplicas, 1)
    maxReplicas                       = coalesce(var.autoscale.maxReplicas, 3)
    targetCPUUtilizationPercentage    = coalesce(var.autoscale.targetCPUUtilizationPercentage, 600)
    targetMemoryUtilizationPercentage = coalesce(var.autoscale.targetMemoryUtilizationPercentage, 80)
  }

  # Computed values
  values = {
    controller = {
      # Metrics configuration according to inputs
      metrics = {
        enabled = var.enable_metrics
        serviceMonitor = {
          enabled = var.enable_metrics
        }
      }
      # Autoscaling configuration for controller
      autoscaling = local.autoscaling
    }
  }
}

resource "helm_release" "ingress_nginx" {
  name       = var.release_name
  chart      = "ingress-nginx"
  version    = var.chart_version
  namespace  = var.namespace
  repository = "https://kubernetes.github.io/ingress-nginx"
  atomic     = true
  lint       = true # Useful to detect errors during plan

  # Static values and values that need to be templated
  values = compact([
    file("${path.module}/base-values.yml"),
    var.kind ? file("${path.module}/kind-values.yml") : null,
    var.custom_error_pages ? file("${path.module}/error-pages-values.yml") : null,
    (var.digitalocean ? templatefile("${path.module}/digitalocean-values.yml", {
      load_balancer_hostname = var.load_balancer_hostname
      default                = var.default_ingress
      ingress_class_name     = local.ingress_class_name
    }) : null),
    local.resources_config,
    # Additional values from the module
    yamlencode(local.values),
    # Additional extra values to pass to the chart
    var.extra_values != null ? yamlencode(var.extra_values) : null,
  ])


  # Ensure the custom error pages are created before the ingress controller is deployed
  depends_on = [kubernetes_config_map_v1.ingress_custom_error_pages]
}

resource "kubernetes_config_map_v1" "ingress_custom_error_pages" {
  count = var.custom_error_pages ? 1 : 0
  metadata {
    name      = "ingress-custom-error-pages"
    namespace = kubernetes_namespace_v1.namespace.metadata.0.name
  }

  data = {
    # Sensitive is only used to avoid showing the content in the plan
    "404.html" = sensitive(file("${path.module}/nginx-error-pages/404.html"))
    "503.html" = sensitive(file("${path.module}/nginx-error-pages/503.html"))
  }
}

data "digitalocean_loadbalancer" "cluster_lb" {
  count      = var.digitalocean ? 1 : 0
  name       = var.load_balancer_hostname
  depends_on = [helm_release.ingress_nginx] # Await for the load balancer to be created
}
