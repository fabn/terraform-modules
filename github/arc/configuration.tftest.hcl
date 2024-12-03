provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-kind"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "kind-kind"
  }
}

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

run "multiple_runners" {
  command = plan
  variables {
    github_token = "gx_xxxxxxx"
    runners = {
      foo = {}
      bar = {}
    }
  }

  assert {
    condition = alltrue([
      kubernetes_namespace_v1.runners.metadata.0.name == var.runners_namespace,
      length(helm_release.runners) == 2,
      helm_release.runners["foo"] != null,
      helm_release.runners["bar"] != null,
    ])
    error_message = "Multiple runners not correctly configured"
  }
}

run "custom_pod_spec" {
  variables {
    github_token = "gx_xxxxxxx"
    runners = {
      foo = {
        spec = {
          resources = {
            limits = {
              cpu    = "1"
              memory = "2Gi"
            }
          }
        }
      }
    }
  }

  assert {
    condition = alltrue([
      length(output.scale_sets) == 1,
      data.kubernetes_resource.scale_sets["foo"] != null,
      # yamldecode(helm_release.runners.values["foo"]).spec.resources.limits.cpu == "1",
      # yamldecode(helm_release.runners.values[0]).spec.resources.limits.memory == "2Gi",
    ])
    error_message = "Custom pod spec not correctly configured"
  }
}
