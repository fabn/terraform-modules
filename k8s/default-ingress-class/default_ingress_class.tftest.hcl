provider "kubernetes" {
  alias          = "kind"
  config_path    = "~/.kube/config"
  config_context = "kind-kind"
}

provider "kubernetes" {
  alias          = "live-cluster"
  config_path    = "~/.kube/config"
  config_context = "live-cluster"
}

run "existing_default_ingress_class" {
  providers = {
    kubernetes = kubernetes.live-cluster
  }

  assert {
    condition     = output.exist == true
    error_message = "Wrong ingress class detection"
  }

  assert {
    condition     = output.name == "nginx" # As configured in live cluster
    error_message = "Wrong ingress class name returned"
  }
}

run "missing_default_ingress_class" {
  providers = {
    kubernetes = kubernetes.kind
  }

  assert {
    condition     = output.exist == false
    error_message = "Wrong ingress class detection"
  }

  assert {
    condition     = output.name == null
    error_message = "Wrong ingress class name returned"
  }
}
