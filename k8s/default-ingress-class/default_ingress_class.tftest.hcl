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

run "missing_default_ingress_class" {
  assert {
    condition     = output.exist == false
    error_message = "Wrong ingress class detection"
  }

  assert {
    condition     = output.name == null
    error_message = "Wrong ingress class name returned"
  }
}

run "nginx" {
  variables {
    kind = true
  }

  module {
    source = "../ingress-controller-nginx"
  }
}

run "existing_default_ingress_class" {
  assert {
    condition     = output.exist == true
    error_message = "Wrong ingress class detection"
  }

  assert {
    condition     = output.name == run.nginx.ingress_class_name
    error_message = "Wrong ingress class name returned"
  }
}
