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
  github_config_url     = "https://github.com/fabn/terraform-modules"
  scale_set_name_prefix = "arc-test"
  github_token          = "gh-some-secret-token"
  runner_group          = "e2e-tests"
}

run "authentication" {
  command = plan
  variables {
    github_token         = null
    github_config_secret = null
  }

  expect_failures = [helm_release.runners]
}

run "app_authentication" {
  command = plan
  variables {
    github_config_secret = {
      github_app_id              = "XXXX"
      github_app_installation_id = "YYYY"
      github_app_private_key     = "ZZZZ"
    }
  }

  assert {
    condition = alltrue([
      length(helm_release.runners.values) == 1,
      yamldecode(helm_release.runners.values[0]).githubConfigSecret.github_app_id == "XXXX",
      yamldecode(helm_release.runners.values[0]).githubConfigSecret.github_app_installation_id == "YYYY",
    ])
    error_message = "Configure auth within yaml file"
  }
}

run "runners" {
  assert {
    condition     = startswith(output.scale_set_name, "arc-test-")
    error_message = "Configure a random prefix for the scale set name"
  }
}