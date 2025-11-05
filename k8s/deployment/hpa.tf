variable "create_hpa" {
  description = "Whether to create a horizontal pod autoscaler or not"
  default     = false
  type        = bool
}

variable "hpa_params" {
  description = "The parameters for the horizontal pod autoscaler"
  type = object({
    min_replicas = optional(number)
    max_replicas = number
    # List of metric_name => average value
    pod_metrics = optional(map(string))
  })
  default  = null
  nullable = true
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "hpa" {
  count = var.create_hpa ? 1 : 0
  metadata {
    name      = "${var.name}-hpa"
    namespace = kubernetes_deployment_v1.deployment.metadata[0].namespace
    labels    = kubernetes_deployment_v1.deployment.spec[0].selector[0].match_labels
  }
  spec {
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment_v1.deployment.metadata[0].name
    }
    # If not given defaults to 1
    min_replicas = coalesce(var.hpa_params.min_replicas, 1)
    max_replicas = var.hpa_params.max_replicas

    # Pod metrics
    dynamic "metric" {
      for_each = var.hpa_params.pod_metrics
      content {
        type = "Pods"
        pods {
          metric {
            name = metric.key
          }
          target {
            type          = "Value"
            average_value = metric.value
          }
        }
      }
    }
  }
}
