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

  variables {
    admin_password = "superSecret1234"
  }

  assert {
    condition     = output.release_name == "rancher"
    error_message = "Wrong release name"
  }

  assert {
    condition     = output.server_url == "http://rancher.lvh.me"
    error_message = "It outputs server url for ${var.hostname}"
  }

  assert {
    condition = alltrue([
      output.bootstrap_password != null,
      output.current_admin_password != var.admin_password,
    ])
    error_message = "It manages passwords"
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
    condition     = output.server_url == "http://rancher.lvh.me"
    error_message = "It outputs server url for ${var.hostname}"
  }
}
