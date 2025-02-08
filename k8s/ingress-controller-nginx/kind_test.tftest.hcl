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
    kind               = true
    custom_error_pages = true
  }

  assert {
    condition     = output.release_name == "ingress-nginx"
    error_message = "Wrong release name"
  }

  assert {
    condition     = output.namespace == "ingress-nginx"
    error_message = "Wrong namespace"
  }

  assert {
    condition     = output.ingress_class_name == "nginx"
    error_message = "Wrong ingress class name"
  }

  assert {
    condition     = length(output.chart_version) > 0
    error_message = "Chart version not emitted"
  }
}

run "http_echo" {
  variables {
    ingress_hostname = "echo.lvh.me"
    image            = "ealen/echo-server:latest"
    name             = "echo"
    namespace        = run.install_helm_release.namespace
    create_namespace = false
  }

  module {
    source = "../http-deployment"
  }
}

run "curl" {
  variables {
    url = run.http_echo.url
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
    condition     = lookup(jsondecode(output.response_body), "host").hostname == run.http_echo.host
    error_message = "Echo deployment not working as expected"
  }
}

run "curl_404_page" {
  variables {
    url          = "http://not-found.${run.http_echo.host}"
    status_codes = [404]
  }

  module {
    source = "../../misc/http"
  }

  assert {
    condition     = output.status_code == 404
    error_message = "Wrong status code returned"
  }

  # Query the echo service to check if it is working as expected returning the hostname in JSON response
  assert {
    condition     = strcontains(output.response_body, "UH OH! You're lost.")
    error_message = "Echo deployment not working as expected"
  }
}

