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
    dd_tags = {
      service = "echo"
      env     = "beta"
      version = "1.0.0"
      team    = "platform"
    }
  }

  assert {
    condition = alltrue([
      kubernetes_deployment_v1.deployment.metadata.0.labels["tags.datadoghq.com/env"] == "beta",
      kubernetes_deployment_v1.deployment.metadata.0.labels["tags.datadoghq.com/service"] == "echo",
      kubernetes_deployment_v1.deployment.metadata.0.labels["tags.datadoghq.com/version"] == "1.0.0",
    ])
    error_message = "Misconfigured annotations in the metadata of the deployment"
  }

  assert {
    condition = alltrue([
      kubernetes_deployment_v1.deployment.spec.0.template.0.metadata.0.labels["tags.datadoghq.com/env"] == "beta",
      kubernetes_deployment_v1.deployment.spec.0.template.0.metadata.0.labels["tags.datadoghq.com/service"] == "echo",
      kubernetes_deployment_v1.deployment.spec.0.template.0.metadata.0.labels["tags.datadoghq.com/version"] == "1.0.0",
    ])
    error_message = "Misconfigured annotations in the deployment template"
  }
}

run "log_tags" {
  command = plan
  variables {
    dd_tags = {
      service = "echo"
    }
  }

  assert {
    condition = output.log_configuration == {
      service = "echo",
    }
    error_message = "Misconfigured annotations in the metadata of the deployment"
  }

  assert {
    condition = jsondecode(output.log_annotations["ad.datadoghq.com/echo.logs"]) == [{
      service = "echo",
    }]
    error_message = "Misconfigured annotations in the metadata of the deployment"
  }

  assert {
    condition = kubernetes_deployment_v1.deployment.spec.0.template.0.metadata.0.annotations["ad.datadoghq.com/echo.logs"] == jsonencode([{
      service = "echo",
    }])
    error_message = "Misconfigured annotations in the deployment template"
  }
}
