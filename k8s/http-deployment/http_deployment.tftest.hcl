provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-kind"
}

run "http_ingress" {
  variables {
    name             = "echo-server"
    ingress_hostname = "echo-server.lvh.me"
    namespace        = "echo-server"
    image            = "ealen/echo-server:latest"
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
    source = "./curl"
  }

  assert {
    condition     = output.status_code == 200
    error_message = "Wrong status code returned"
  }

  # Query the echo service to check if it is working as expected returning the hostname in JSON response
  assert {
    condition     = lookup(jsondecode(output.response_body), "host").hostname == run.http_ingress.host
    error_message = "Echo deployment not working as expected"
  }
}
