variables {
  create_namespace = true
  # These are the minimal requirements to have a deployment using this module
  name                   = "echo"
  namespace              = "service-monitor-test"
  image                  = "ealen/echo-server:latest"
  create_service_monitor = true
  ports                  = { metrics = 9394 }
}

# Mock the manifest resource since kind doesn't have the monitoring.coreos.com/v1 API
mock_provider "kubernetes" {
  mock_resource "kubernetes_manifest" {
  }
}

run "with_service_monitor" {
  command = plan
  assert {
    condition     = kubernetes_manifest.service_monitor[0].manifest.metadata["name"] == "echo-service-monitor"
    error_message = "Uses the proper name"
  }

  assert {
    condition = alltrue([
      kubernetes_manifest.service_monitor[0].manifest.spec["endpoints"][0]["port"] == "metrics",
      kubernetes_manifest.service_monitor[0].manifest.spec["endpoints"][0]["interval"] == "30s",
    ])
    error_message = "Configures the endpoints"
  }

  assert {
    condition = alltrue([
      kubernetes_manifest.service_monitor[0].manifest.metadata["labels"] == tomap(output.labels),
      kubernetes_manifest.service_monitor[0].manifest.spec["selector"]["matchLabels"] == tomap(output.labels),
    ])
    error_message = "Labels are not set on service monitor"
  }
}
