terraform {
  required_providers {
    null = {
      source = "hashicorp/null"
    }
    time = {
      source = "hashicorp/time"
    }
  }
}
variable "type" {
  description = "The type of the object to patch (e.g. namespace)"
  type        = string
  default     = "namespace" # The most common use case
}
variable "name" {
  description = "The name of resource to patch"
  type        = string
}
variable "namespace" {
  description = "The namespace to pass to kubectl"
  type        = string
}

variable "sleep_for" {
  description = "The duration to sleep for before patching the finalizer"
  default     = "30s"
}

resource "time_sleep" "wait" {
  destroy_duration = "30s"
}

resource "null_resource" "remove_finalizers" {
  depends_on = [time_sleep.wait]
  provisioner "local-exec" {
    command = <<EOT
      kubectl patch ${var.type}/${var.name} -n ${var.namespace} --type json --patch='[ { "op": "remove", "path": "/metadata/finalizers" } ]'
    EOT
  }
}
