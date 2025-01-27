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
  hostname    = "rancher.fabn.dev"
  replicas    = 1
  self_signed = true
}

# Base installation with no ingress controller, only verify module logics
run "install_helm_release" {
  command = plan

  variables {
    bootstrap_password = "superBootstrap1234"
    admin_password     = "superSecret1234"
  }

  assert {
    condition     = output.release_name == "rancher"
    error_message = "Wrong release name"
  }

  assert {
    condition     = output.server_url == "https://rancher.fabn.dev"
    error_message = "It outputs server url for ${var.hostname}"
  }

  assert {
    condition = alltrue([
      output.bootstrap_password == var.bootstrap_password,
      output.admin_password == var.admin_password,
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
    source = "../ingress-controller-nginx"
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
    condition     = output.server_url == "https://rancher.fabn.dev"
    error_message = "It outputs server url for ${var.hostname}"
  }
}

run "test_login" {
  variables {
    url             = "${run.install_full_release.server_url}/v3-public/localProviders/local?action=login"
    method          = "POST"
    skip_tls_verify = true
    status_codes    = [201]
    request_headers = {
      Content-Type = "application/json"
    }
    request_body = jsonencode({
      username = "admin",
      password = run.install_full_release.admin_password
    })
  }

  module {
    source = "../../misc/http"
  }

  assert {
    condition     = output.status_code == 200
    error_message = "It responds with 200 at ${var.url}"
  }

  assert {
    condition = alltrue([
      length(jsondecode(output.response_body).token) > 0,
      startswith(jsondecode(output.response_body).token, "token")
    ])
    error_message = "It returns a valid token"
  }
}
