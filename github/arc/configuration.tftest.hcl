variables {
  github_config_url = "https://github.com/acme"
}

run "controller_overrides" {
  command = plan
  variables {
    github_token = "gx_xxxxxxx"
    controller_override_values = yamlencode({
      controller = {
        replicaCount = 2
      }
    })
  }

  assert {
    condition = alltrue([
      length(helm_release.arc.values) == 1,
      yamldecode(helm_release.arc.values[0]).controller.replicaCount == 2,
    ])
    error_message = "YAML not correctly encoded"
  }
}
