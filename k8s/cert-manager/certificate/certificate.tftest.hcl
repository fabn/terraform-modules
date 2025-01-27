provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-kind"
}

provider "kubectl" {
  config_path    = "~/.kube/config"
  config_context = "kind-kind"
}

variables {
  issuer           = "letsencrypt-cluster-issuer"
  certificate_name = "star-dot-dev"
  dns_names        = ["*.test.fabn.dev"]
}

run "crd" {
  module {
    source = "../../crd"
  }
  variables {
    url = "https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.crds.yaml"
  }
}

run "create_test" {
  variables {
    wait = false
  }
  assert {
    condition     = run.crd.crds["issuers.cert-manager.io"] != null
    error_message = "CRD not found"
  }

  assert {
    condition     = output.secret.metadata[0].name == "star-dot-dev-tls"
    error_message = "Plan failed"
  }
}
