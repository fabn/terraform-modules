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
  hostname = "rancher.lvh.me"
  replicas = 1
}

run "install_helm_release" {
  assert {
    condition     = output.release_name == "rancher"
    error_message = "Wrong release name"
  }

  assert {
    condition     = output.server_url == "http://rancher.lvh.me"
    error_message = "It outputs server url for ${var.hostname}"
  }
}
