terraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = ">= 8"
    }
  }
}
# bootstrap and admin password
resource "random_password" "bootstrap" {
  count  = var.bootstrap_password == null ? 1 : 0
  length = 16
}

resource "random_password" "admin" {
  count  = var.admin_password == null ? 1 : 0
  length = 16
}

locals {
  bootstrap_password = var.bootstrap_password != null ? var.bootstrap_password : random_password.bootstrap[0].result
  admin_password     = var.admin_password != null ? var.admin_password : random_password.admin[0].result
}


# Bootstrap the rancher installation
resource "rancher2_bootstrap" "admin" {
  # Used to bootstrap the rancher installation
  initial_password = local.bootstrap_password
  # Will be kept in sync for the admin user
  password = local.admin_password
  # By default generate a token that doesn't expire
  token_ttl = 0
}
