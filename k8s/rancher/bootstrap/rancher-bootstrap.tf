terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = ">= 8"
    }
  }
}

resource "random_password" "admin" {
  count  = var.admin_password == null ? 1 : 0
  length = 16
}

locals {
  admin_password = var.admin_password != null ? var.admin_password : random_password.admin[0].result
}


# Bootstrap the rancher installation
resource "rancher2_bootstrap" "admin" {
  # Used to bootstrap the rancher installation
  initial_password = var.bootstrap_password
  # Will be kept in sync for the admin user
  password = local.admin_password
  # By default generate a token that doesn't expire
  token_ttl = 0
  # Refresh the token on each apply when expired
  token_update = var.token_update
}
