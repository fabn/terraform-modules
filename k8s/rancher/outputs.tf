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
  value       = random_password.bootstrap.result
  sensitive   = true
}

output "current_admin_password" {
  description = "The current password for the admin user"
  value       = local.admin_password
  sensitive   = true
}

output "server_url" {
  description = "The server url for rancher"
  value       = local.server_url
}

output "rancher_token" {
  description = "The token to access the rancher API"
  value = {
    token    = rancher2_bootstrap.admin.token,
    token_id = rancher2_bootstrap.admin.token_id
  }
  sensitive = true
}
