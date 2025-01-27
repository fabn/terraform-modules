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

  assert {
    condition = alltrue([
      output.spec.issuerRef.kind == "ClusterIssuer", # Default value of var
      output.spec.issuerRef.name == var.issuer,
      toset(output.spec.dnsNames) == toset(var.dns_names),
      output.certificate.name == var.certificate_name,
      output.certificate.namespace == var.namespace
    ])
    error_message = "Certificate attributes mismatching"
  }
}

run "issuer_test" {
  variables {
    issuer_kind = "Issuer"
    namespace   = "default"
    wait        = false
  }

  assert {
    condition = alltrue([
      output.spec.issuerRef.kind == "Issuer",
      output.spec.issuerRef.name == var.issuer,
      output.certificate.namespace == var.namespace
    ])
    error_message = "Certificate attributes mismatching"
  }

}
