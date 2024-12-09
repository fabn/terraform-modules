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

run "install_helm_release" {
  variables {
    kind = true
  }

  assert {
    condition     = output.release_name == "metrics-server"
    error_message = "Wrong release name"
  }

  assert {
    condition     = output.namespace == "metrics-server"
    error_message = "Wrong namespace"
  }

  assert {
    condition     = length(output.chart_version) > 0
    error_message = "Chart version not emitted"
  }
}
