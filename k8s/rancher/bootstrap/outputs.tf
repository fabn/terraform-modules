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

output "rancher_token" {
  description = "The tokens to access the rancher API"
  value = {
    api_token  = rancher2_bootstrap.admin.token,
    access_key = rancher2_bootstrap.admin.token_id
    secret_key = split(":", rancher2_bootstrap.admin.token)[1]
  }
  sensitive = true
}
