terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
}

variable "name" {
  description = "The name of the cluster to create"
  type        = string
  validation {
    condition     = length(var.name) > 0
    error_message = "A cluster name must be set"
  }
}

variable "region" {
  description = "The slug of the region to use"
  type        = string
}

variable "node_count" {
  description = "The number of nodes to create in the cluster"
  default     = 3
  type        = number
}

variable "node_size" {
  description = "The size of the nodes to create in the cluster"
  default     = "s-2vcpu-4gb"
  type        = string
}

variable "auto_scale" {
  description = "Enable auto scaling for the default node pool"
  default = {
    enabled   = false
    min_nodes = 3
    max_nodes = 5
  }
  type = object({
    enabled   = bool
    min_nodes = number
    max_nodes = number
  })
}

# Fetch last kubernetes version available in the region
data "digitalocean_kubernetes_versions" "available" {}

resource "digitalocean_kubernetes_cluster" "cluster" {
  name   = var.name
  region = var.region
  # Always use the latest version
  auto_upgrade  = true
  surge_upgrade = true
  # Current highest cluster version
  # see also doctl kubernetes options versions to get slugs of available versions
  version = data.digitalocean_kubernetes_versions.available.latest_version

  # A sane default
  maintenance_policy {
    day        = "any"
    start_time = "01:00"
  }

  node_pool {
    name       = "default"
    size       = var.node_size
    node_count = var.node_count
    auto_scale = var.auto_scale.enabled
    min_nodes  = var.auto_scale.min_nodes
    max_nodes  = var.auto_scale.max_nodes
  }
  lifecycle {
    ignore_changes = [
      version,               # Since there's auto_upgrade, we don't want to have a config drift when the version is updated
      node_pool.0.node_count # Can be managed by auto_scale, so we don't want to change it on reconciliation
    ]
  }
}

output "cluster" {
  value = digitalocean_kubernetes_cluster.cluster
}

output "endpoint" {
  value = digitalocean_kubernetes_cluster.cluster.endpoint
}

# Sample kubernetes provider configuration
# provider "kubernetes" {
#   host  = digitalocean_kubernetes_cluster.cluster.endpoint
#   token = digitalocean_kubernetes_cluster.cluster.kube_config[0].token
#   cluster_ca_certificate = base64decode(
#     digitalocean_kubernetes_cluster.cluster.kube_config[0].cluster_ca_certificate
#   )
# }
