provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-kind"
}

provider "helm" {
  kubernetes = {
    config_path    = "~/.kube/config"
    config_context = "kind-kind"
  }
}

variables {
  hostname = "rancher.fabn.dev"
  replicas = 1
}

run "values_output" {
  command = plan

  assert {
    condition     = keys(output.values) == []
    error_message = "Values output is not empty"
  }

  assert {
    condition     = output.values == {}
    error_message = "Values output is not empty"
  }
}
