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
  value       = one(helm_release.rancher.metadata).version
}

output "bootstrap_password" {
  description = "The bootstrap password"
  value       = local.bootstrap_password
  sensitive   = true
}
