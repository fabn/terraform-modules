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

output "admin_password" {
  description = "The current password for the admin user"
  value       = local.admin_password
  sensitive   = true
}

output "server_url" {
  description = "The server url for rancher"
  value       = local.server_url
}

output "rancher_token" {
  description = "The tokens to access the rancher API"
  value = {
    api_token  = rancher2_bootstrap.admin.token,
    access_key = rancher2_bootstrap.admin.token_id
    secret_key = split(":", rancher2_bootstrap.admin.token)[1]
  }
  sensitive = true
}

output "values" {
  description = "Rendered values through values attributes as object"
  value       = yamldecode(join("\n", helm_release.rancher.values))
  sensitive   = true
}

output "set" {
  description = "Set values through values attributes as object"
  value       = { for s in nonsensitive(helm_release.rancher.set) : s.name => s.value if s.name != "globalConfig.signing_key" }
  sensitive   = true
}
