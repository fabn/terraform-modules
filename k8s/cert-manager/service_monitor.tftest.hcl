
provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-kind"
}


run "crd" {
  module {
    source = "../crd"
  }
  variables {
    # Install CRDs for ServiceMonitor
    url = "https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/refs/heads/main/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml"
  }
}

run "helm_release" {
  command = plan

  assert {
    condition     = output.set["prometheus.servicemonitor.enabled"] == "true"
    error_message = "It sets up the service monitor"
  }
}
