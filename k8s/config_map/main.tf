terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

variable "namespace" {
  description = "The namespace for the config map, must exist"
  type        = string
}

variable "name_prefix" {
  description = "The prefix to use for the config map"
  type        = string
}


variable "data" {
  description = "The data to store in the config map"
  type        = map(string)
  default     = {}
}

variable "binary_data" {
  description = "The binary data to store in the config map"
  type        = map(string)
  default     = {}
}

locals {
  sha = substr(sha256(jsonencode(merge(var.data, var.binary_data))), 0, 8)
}

resource "kubernetes_config_map_v1" "config_map" {
  metadata {
    namespace = var.namespace
    name      = join("-", [var.name_prefix, local.sha])
  }

  data        = var.data
  binary_data = var.binary_data
}

output "config_map" {
  description = "The whole object"
  value       = kubernetes_config_map_v1.config_map
}

output "name" {
  description = "Generated name for created config map"
  value       = one(kubernetes_config_map_v1.config_map.metadata).name
}
