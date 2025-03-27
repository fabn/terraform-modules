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

run "ingress_controller" {
  module {
    source = "../ingress-controller-nginx"
  }

  variables {
    kind = true
  }
}

run "http_ingress" {
  variables {
    name             = "echo-server"
    ingress_hostname = "echo-server.lvh.me"
    namespace        = run.ingress_controller.namespace
    create_namespace = false
    image            = "ealen/echo-server:latest"
    ingress_annotations = {
      "nginx.ingress.kubernetes.io/proxy-buffering"       = "on"
      "nginx.ingress.kubernetes.io/configuration-snippet" = <<-EOT
        add_header X-Test "test";
    EOT
    }
  }

  assert {
    condition     = output.host == var.ingress_hostname
    error_message = "Wrong hostname returned"
  }

  assert {
    condition     = output.url == "http://${var.ingress_hostname}"
    error_message = "Wrong deployment URL returned"
  }
}

run "curl_to_ingress" {
  variables {
    url = run.http_ingress.url # Reference the output from the previous run block
  }

  module {
    source = "../../misc/http"
  }

  assert {
    condition     = output.status_code == 200
    error_message = "Wrong status code returned"
  }

  # Query the echo service to check if it is working as expected returning the hostname in JSON response
  assert {
    condition     = output.parsed.host.hostname == run.http_ingress.host
    error_message = "Echo deployment not working as expected"
  }

  assert {
    condition     = output.headers["X-Test"] == "test"
    error_message = "Configured snippet not applied"
  }
}
