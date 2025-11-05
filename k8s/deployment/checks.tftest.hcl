variables {
  create_namespace = true
  # These are the minimal requirements to have a deployment using this module
  name      = "echo"
  namespace = "deployment-test"
  image     = "ealen/echo-server:latest"
}

# e.g for apache
# init_config:
#
# instances:
#   ## @param apache_status_url - string - required
#   ## Status url of your Apache server.
#   #
#   - apache_status_url: http://localhost/server-status?auto

run "minimal_deploy" {
  command = plan
  variables {
    dd_checks = {
      apache = {
        instances = [{
          status_url = "http://localhost/server-status?auto"
        }]
      }
    }
  }

  assert {
    condition     = kubernetes_deployment_v1.deployment.spec.0.template.0.metadata.0.annotations != null
    error_message = "Misconfigured annotations in the deployment"
  }


  assert {
    condition = output.container_checks.apache == {
      init_config = {}
      instances = [
        {
          status_url = "http://localhost/server-status?auto"
        }
      ]

    }
    error_message = "Misconfigured annotations in the deployment"
  }
}
