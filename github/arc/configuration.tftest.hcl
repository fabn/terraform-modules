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
  github_token      = "gx_xxxxxxx"
}

run "controller_overrides" {
  command = plan
  variables {
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

run "custom_pod_resources" {
  command = plan
  variables {
    runners = {
      foo = {
        requests = {
          cpu    = "500m"
          memory = "1Gi"
        }
        limits = {
          memory = "2Gi"
        }
      }
    }
  }

  assert {
    condition = alltrue([
      yamldecode(helm_release.runners["foo"].values[1]).template.spec.containers[0].name == "runner",
      yamldecode(helm_release.runners["foo"].values[1]).template.spec.containers[0].resources.limits.memory == "2Gi",
      yamldecode(helm_release.runners["foo"].values[1]).template.spec.containers[0].resources.requests.memory == "1Gi",
      yamldecode(helm_release.runners["foo"].values[1]).template.spec.containers[0].resources.requests.cpu == "500m",
    ])
    error_message = "Custom pod spec not correctly configured"
  }
}

run "pod_values" {
  command = plan
  variables {
    runners = {
      foo = {
        values = yamlencode({
          template = {
            spec = {
              replicas = 2
            }
          }
        })
      }
    }
  }

  assert {
    condition = alltrue([
      yamldecode(helm_release.runners["foo"].values[2]).template.spec.replicas == 2,
    ])
    error_message = "Custom values not correctly configured"
  }
}

run "container_mode" {
  command = plan
  variables {
    runners = {
      foo = {
        containerMode = "dind"
      }
    }
  }

  assert {
    condition     = output.set["foo"]["containerMode.kind"] == "dind"
    error_message = "Custom values not correctly configured"
  }
}
