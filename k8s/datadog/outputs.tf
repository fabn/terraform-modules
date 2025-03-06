output "chart_version" {
  description = "Installed chart version of the datadog operator chart"
  value       = one(helm_release.datadog_operator.metadata).version
}
