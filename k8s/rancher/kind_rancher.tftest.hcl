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

# Base installation with no ingress controller, only verify module logics
run "install_helm_release" {
  command = plan
  assert {
    condition     = output.release_name == "rancher"
    error_message = "Wrong release name"
  }

  assert {
    condition     = output.server_url == "http://rancher.lvh.me"
    error_message = "It outputs server url for ${var.hostname}"
  }
}

# Full installation to expose it
run "nginx" {
  variables {
    kind = true
  }

  module {
    source = "../ingress-controller-nginx/kind_test"
  }
}

run "install_full_release" {
  variables {
    hostname = var.hostname
    # Passed to make test dependent on ingress controller
    ingress_class_name = run.nginx.ingress_class_name
  }

  assert {
    condition     = output.release_name == "rancher"
    error_message = "Wrong release name"
  }

  assert {
    condition     = output.server_url == "https://rancher.lvh.me"
    error_message = "It outputs server url for ${var.hostname}"
  }
}
