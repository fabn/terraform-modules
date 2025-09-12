output "release_name" {
  description = "The name of the helm release"
  value       = helm_release.rancher.name
}

# Used in testing
output "namespace" {
  description = "The namespace where rancher has been deployed"
  value       = helm_release.rancher.namespace
}

output "chart_version" {
  description = "Installed chart version"
  value       = helm_release.rancher.metadata.version
}

output "bootstrap_password" {
  description = "The bootstrap password"
  value       = local.bootstrap_password
  sensitive   = true
}

output "server_url" {
  description = "The server url for rancher"
  value       = local.server_url
}

locals {
  yaml_values = length(helm_release.rancher.values) > 0 ? join("\n", helm_release.rancher.values) : "{}"
}

output "values" {
  description = "Rendered values through values attributes as object"
  value       = yamldecode(local.yaml_values)
  sensitive   = true
}

output "set" {
  description = "Set values through values attributes as object"
  value       = { for s in nonsensitive(helm_release.rancher.set) : s.name => s.value if s.name != "globalConfig.signing_key" }
  sensitive   = true
}

output "hostname" {
  description = "The hostname used to access rancher"
  value       = var.hostname
}
