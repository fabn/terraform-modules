variables {
  container_name = "demo"
}

run "default" {
  variables {
    checks = {
      apache = {
        instances = [{
          status_url = "http://localhost/server-status?auto"
        }]
      }
    }
  }

  assert {
    condition     = output.checks_annotation_key == "ad.datadoghq.com/demo.checks"
    error_message = "Check annotations has the proper key"
  }

  assert {
    condition = output.checks == {
      "apache" = {
        init_config = {}
        instances = [
          {
            status_url = "http://localhost/server-status?auto"
          }
        ]
      }
    }
    error_message = "Proper checks are configured in the deployment"
  }

  assert {
    condition = output.annotations["ad.datadoghq.com/demo.checks"] == jsonencode({
      apache = {
        init_config = {}
        instances = [
          {
            status_url = "http://localhost/server-status?auto"
          }
        ]
      }
    })
    error_message = "Proper checks are configured in annotations"
  }
}

run "with_no_checks" {
  variables {
    checks = {}
  }

  assert {
    condition     = output.checks == null
    error_message = "Checks should be null when no checks are provided"
  }

  assert {
    condition     = output.annotations == null
    error_message = "Annotations should be null when no checks are provided"
  }
}

run "builtin_check_by_id" {
  variables {
    check_id = "httpd"
  }

  assert {
    condition     = output.annotations["ad.datadoghq.com/demo.check.id"] == var.check_id
    error_message = "Proper checks are configured in annotations"
  }
}
