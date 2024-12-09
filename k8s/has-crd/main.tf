terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

variable "name" {
  description = "The name of the crd to check"
  type        = string
}

data "kubernetes_resources" "crd" {
  api_version    = "apiextensions.k8s.io/v1"
  kind           = "CustomResourceDefinition"
  field_selector = "metadata.name==${var.name}"
}

output "has_crd" {
  description = "Whether the cluster has CRDs installed"
  value       = length(data.kubernetes_resources.crd.objects) > 0
}
