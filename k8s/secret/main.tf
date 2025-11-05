terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

variable "namespace" {
  description = "The namespace for the secret, must exist"
  type        = string
}

variable "name_prefix" {
  description = "The prefix to use for the secret"
  type        = string
}

variable "type" {
  description = "The type of the secret"
  nullable    = true
  type        = string
  default     = null
}

variable "data" {
  description = "The data to store in the secret"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "binary_data" {
  description = "The binary data to store in the secret"
  type        = map(string)
  default     = {}
  sensitive   = true
}

locals {
  sha = substr(sha256(jsonencode(merge(var.data, var.binary_data))), 0, 8)
}

resource "kubernetes_secret_v1" "secret" {
  metadata {
    namespace = var.namespace
    name      = join("-", [var.name_prefix, local.sha])
  }

  type = var.type

  data        = var.data
  binary_data = var.binary_data
}


output "secret" {
  description = "The whole object"
  value       = kubernetes_secret_v1.secret
}

output "name" {
  description = "Generated name for created secret"
  value       = nonsensitive(one(kubernetes_secret_v1.secret.metadata).name)
}
