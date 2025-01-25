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
    hostname      = "rancher.lvh.me"
    chart_version = "2.8.4"
  }

  assert {
    condition     = output.release_name == "rancher"
    error_message = "Wrong release name"
  }
}
