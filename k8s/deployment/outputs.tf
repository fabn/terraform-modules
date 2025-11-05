output "name" {
  description = "The name of the deployment (and additional resources)"
  value       = var.name
}

output "service_name" {
  description = "The name of the service"
  value       = length(kubernetes_service_v1.service) > 0 ? kubernetes_service_v1.service[0].metadata[0].name : null
}

output "deployment" {
  description = "The whole deployment object"
  value       = kubernetes_deployment_v1.deployment
}

output "service" {
  description = "The whole service object"
  value       = one(kubernetes_service_v1.service)
}

output "ingress" {
  description = "The whole ingress object"
  value       = one(kubernetes_ingress_v1.ingress)
}

output "labels" {
  description = "The labels used in the deployment"
  value       = local.labels
}

output "log_configuration" {
  description = "The log tags used for the pod"
  value       = module.log_annotations.tags
}

output "log_annotations" {
  description = "The log annotations used for the pod"
  value       = module.log_annotations.annotations
}


output "container_checks" {
  description = "The check tags used for the pod"
  value       = module.log_annotations.checks
}
