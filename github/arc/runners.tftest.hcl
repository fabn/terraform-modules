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
  scale_set_name_prefix = "arc-test-"
  github_token          = "gh-some-secret-token"
}

run "authentication" {
  command = plan
  variables {
    github_token         = null
    github_config_secret = null
  }

  expect_failures = [helm_release.runners]
}

run "runners" {
  assert {
    condition     = startswith(output.scale_set_name, "arc-test-")
    error_message = "Configure a random prefix for the scale set name"
  }
}
