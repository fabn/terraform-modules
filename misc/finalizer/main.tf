terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "3.2.3"
    }
  }
}

variable "type" {
  description = "The type of the object to patch (e.g. namespace)"
  type        = string
}
variable "name" {
  description = "The name of resource to patch"
  type        = string
}
variable "namespace" {
  description = "The namespace to pass to kubectl"
  type        = string
}

resource "null_resource" "remove_finalizers" {
  provisioner "local-exec" {
    command = <<EOT
      kubectl patch ${var.type} ${var.name} -n ${var.namespace} --type=merge -p '{"metadata":{"finalizers":[]}}'
    EOT
  }
}
