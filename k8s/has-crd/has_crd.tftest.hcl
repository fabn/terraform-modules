provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "live-cluster"
}

run "when_resource_exist" {
  command = plan
  variables {
    name = "certificates.cert-manager.io"
  }
  assert {
    condition     = output.has_crd == true
    error_message = "CRD not detected"
  }
}

run "when_resources_do_not_exist" {
  command = plan
  variables {
    name = "not-a-crd"
  }

  assert {
    condition     = output.has_crd == false
    error_message = "CRD detected"
  }
}
