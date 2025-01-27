terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

# Retrieve configured ingress class for k8s
data "kubernetes_resources" "default_ingress_class" {
  api_version = "networking.k8s.io/v1"
  kind        = "IngressClass"
}

locals {
  # Get the default ingress class, if any i.e. the one with the relevant annotation
  default_ingress_class = one([
    for ic in data.kubernetes_resources.default_ingress_class.objects : ic
    if try(ic.metadata.annotations["ingressclass.kubernetes.io/is-default-class"], null) == "true"
  ])
  # Store name, returning null if not found
  default_ingress_class_name = try(local.default_ingress_class.metadata.name, null)
}

output "name" {
  description = "Name of default ingress class (may be null)"
  value       = local.default_ingress_class_name
}

output "exist" {
  description = "True if default ingress class exists"
  value       = try(length(local.default_ingress_class_name) > 0, false)
}
