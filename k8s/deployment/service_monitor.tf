resource "kubernetes_manifest" "service_monitor" {
  count = var.create_service_monitor ? 1 : 0
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name = "${var.name}-service-monitor"
      # Make it depend on the deployment
      namespace = kubernetes_deployment_v1.deployment.metadata[0].namespace
      labels    = kubernetes_deployment_v1.deployment.spec[0].selector[0].match_labels
    }

    spec = {

      endpoints = [
        {
          port     = "metrics"
          interval = "30s"
        }
      ]
      selector = {
        matchLabels = kubernetes_service_v1.service[0].metadata[0].labels
      }
    }
  }
}
