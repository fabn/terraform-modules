provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-kind"
}

run "cert-manager" {
  variables {
    url = "https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.crds.yaml"
  }

  # Based on current CRDs content
  assert {
    condition     = length(output.crds) == 6
    error_message = "CRDs not found"
  }

  assert {
    condition = toset(keys(output.crds)) == toset([
      "certificates.cert-manager.io",
      "clusterissuers.cert-manager.io",
      "issuers.cert-manager.io",
      "orders.acme.cert-manager.io",
      "certificaterequests.cert-manager.io",
      "challenges.acme.cert-manager.io"
    ])
    error_message = "CRDs returns the proper specs"
  }
}
