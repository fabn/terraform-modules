variables {
  create_namespace = true
  # These are the minimal requirements to have a deployment using this module
  name      = "echo"
  namespace = "deployment-test"
  image     = "ealen/echo-server:latest"
}

run "minimal_deploy" {
  assert {
    condition     = kubernetes_deployment_v1.deployment.metadata.0.name == "echo"
    error_message = "Uses the proper name"
  }

  assert {
    condition     = kubernetes_deployment_v1.deployment.metadata.0.namespace == var.namespace
    error_message = "Uses the proper namespace"
  }

  assert {
    condition     = kubernetes_deployment_v1.deployment.spec.0.template.0.spec.0.container.0.image == var.image
    error_message = "Uses the proper image"
  }

  assert {
    condition     = length(kubernetes_service_v1.service) == 0
    error_message = "Does not create a service"
  }

  assert {
    condition     = length(kubernetes_ingress_v1.ingress) == 0
    error_message = "Does not create an ingress"
  }

  assert {
    condition = alltrue([
      length(output.labels) == 3,
      output.labels["terraform/app"] == "echo",
      output.labels["terraform/namespace"] == "deployment-test",
      output.labels["terraform/module"] != null
    ])
    error_message = "Labels are not set"
  }

  assert {
    condition = alltrue([
      kubernetes_deployment_v1.deployment.metadata.0.labels == tomap(output.labels),
      kubernetes_deployment_v1.deployment.spec.0.selector.0.match_labels == tomap(output.labels),
      kubernetes_deployment_v1.deployment.spec.0.template.0.metadata.0.labels == tomap(output.labels)
    ])
    error_message = "Labels are not set on deployment"
  }
}
