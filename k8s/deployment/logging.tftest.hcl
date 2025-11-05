variables {
  create_namespace = true
  # These are the minimal requirements to have a deployment using this module
  name      = "echo"
  namespace = "deployment-test"
  image     = "ealen/echo-server:latest"
}

run "minimal_deploy" {
  command = plan
  variables {
    dd_log_tags = {
      service = "echo"
      source  = "echo-server",
      exclude = ["/healthz"]
    }
  }

  assert {
    condition = alltrue([
      contains(keys(kubernetes_deployment_v1.deployment.spec.0.template.0.metadata.0.annotations), "ad.datadoghq.com/${var.name}.logs"),
      output.log_configuration.service == "echo",
      output.log_configuration.source == "echo-server",
    ])
    error_message = "Misconfigured annotations in the deployment"
  }

  assert {
    condition = alltrue([
      length(output.log_configuration.log_processing_rules) == 1,
      output.log_configuration.log_processing_rules[0].type == "exclude_at_match",
      output.log_configuration.log_processing_rules[0].name == "exclude--healthz",
    ])

    error_message = "Exclusions are configured"
  }
}

run "with_no_rules" {
  command = plan

  assert {
    condition     = kubernetes_deployment_v1.deployment.spec.0.template.0.metadata.0.annotations == null
    error_message = "Misconfigured annotations in the deployment"
  }

  assert {
    condition = alltrue([
      output.log_configuration == null,
    ])
    error_message = "Exclusions are configured"
  }
}
