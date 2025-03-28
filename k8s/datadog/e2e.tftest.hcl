provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-kind"
}

provider "kubectl" {
  config_path    = "~/.kube/config"
  config_context = "kind-kind"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "kind-kind"
  }
}

variables {
  cluster_name = "demo"
  dd_api_key   = "1234567890"
  dd_site      = "datadoghq.com"
}


# Real install on kind
run "install" {
  assert {
    condition     = helm_release.datadog_operator.namespace == output.namespace
    error_message = "Operator was not installed"
  }
}

# Patch the agent to remove finalizer otherwise it won't be able to teardown
# Since we're using a dummy key it won't be ready
run "remove_finalizer" {
  module {
    source = "../../misc/finalizer"
  }

  variables {
    type      = "datadogagents.datadoghq.com"
    namespace = install.output.namespace
    name      = "datadog"
  }
}
