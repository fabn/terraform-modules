# Deploy a sample service to demonstrate ingress is working
resource "kubernetes_namespace_v1" "namespace" {
  metadata {
    name = var.namespace
  }
}

locals {
  ingress_class_name = var.default_ingress ? "nginx" : "nginx-${var.release_name}"
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
    }) : null)
  ])


  # set with map needs \\. to escape the dot, see https://getbetterdevops.io/terraform-with-helm/

  # This is a sane default, make them parametric when needed
  set {
    name = "controller\\.resources"
    value = yamlencode({
      limits = {
        memory = "384Mi"
      }
      requests = {
        cpu    = "50m"
        memory = "128Mi"
      }
    })
  }

  # In order to have autoscaling we need to enable metrics
  set {
    name = "controller\\.autoscaling"
    value = yamlencode({
      enabled     = var.enable_metrics
      minReplicas = 1
      maxReplicas = 5
      targetCPUUtilizationPercentage : 600
      targetMemoryUtilizationPercentage : 80
      # TODO: configure custom metric after integrating with prometheus
    })
  }

  # Need prometheus to be installed first
  set {
    name = "controller\\.metrics"
    value = yamlencode({
      enabled = var.enable_metrics
      serviceMonitor = {
        enabled = var.enable_metrics
      }
    })
  }

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

# Kubernetes service created by helm release
data "kubernetes_service_v1" "ingress_service" {
  metadata {
    name = "ingress-nginx-controller" # Possibly parametric when overriding release name
  }
  depends_on = [helm_release.ingress_nginx] # Await for the load balancer to be created
}