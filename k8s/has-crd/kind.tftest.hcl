provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-kind"
}

run "when_resource_exist" {
  command = plan
  variables {
    name = "certificates.cert-manager.io"
  }
  assert {
    condition     = output.has_crd == false
    error_message = "CRD not detected"
  }
}
