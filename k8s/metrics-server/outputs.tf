output "release_name" {
  description = "The name of the helm release"
  value       = helm_release.metrics_server.name
}

# Used in testing
output "namespace" {
  description = "The namespace where the ingress controller is deployed"
  value       = helm_release.metrics_server.namespace
}

output "chart_version" {
  description = "Installed chart version of the metrics server helm chart"
  value       = one(helm_release.metrics_server.metadata).version
}
