terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

locals {
  labels = {
    app = var.name
  }

  use_acme      = length(var.tls_hosts) > 0
  output_scheme = local.use_acme ? "https" : "http"
}

resource "kubernetes_namespace_v1" "ns" {
  count = var.create_namespace ? 1 : 0
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_deployment_v1" "deployment" {
  wait_for_rollout = true # Is the default but keep it
  depends_on       = [kubernetes_namespace_v1.ns]
  metadata {
    name      = "${var.name}-deployment"
    namespace = var.namespace
  }

  spec {
    replicas = 1

    selector {
      match_labels = local.labels
    }

    template {
      metadata {
        labels = local.labels
      }

      spec {
        container {
          name  = var.name
          image = var.image
          port {
            container_port = var.port
          }
          startup_probe {
            http_get {
              path = var.startup_probe_endpoint
              port = var.port
            }
            initial_delay_seconds = 2
            period_seconds        = 5
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "service" {
  wait_for_load_balancer = true # Is default but keep it
  depends_on             = [kubernetes_deployment_v1.deployment]
  metadata {
    name      = "${var.name}-service"
    namespace = var.namespace
  }

  spec {
    selector = local.labels

    port {
      port        = var.port
      target_port = var.port
      name        = "http"
    }
  }
}

# Ingress to expose the echo service
resource "kubernetes_ingress_v1" "ingress" {
  wait_for_load_balancer = true
  metadata {
    name      = "${var.name}-ingress"
    namespace = var.namespace
    # Enable automated certificate management
    annotations = local.use_acme ? { "kubernetes.io/tls-acme" = "true" } : {}
  }

  spec {
    ingress_class_name = var.ingress_class_name
    rule {
      host = var.ingress_hostname
      http {
        path {
          path = "/"
          backend {
            service {
              name = one(kubernetes_service_v1.service.metadata).name
              port {
                name = kubernetes_service_v1.service.spec.0.port.0.name
              }
            }
          }
        }
      }
    }

    dynamic "tls" {
      for_each = var.tls_hosts[*]
      content {
        hosts       = var.tls_hosts
        secret_name = "${var.name}-ingress-tls"
      }
    }
  }
}
