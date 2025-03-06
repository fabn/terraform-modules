variables {
  cluster_name = "demo"
  dd_api_key   = "1234567890"
  dd_site      = "datadoghq.com"
}

run "default_install" {
  command = plan

  assert {
    condition     = kubernetes_namespace.ns.metadata[0].name == var.namespace
    error_message = "Namespace was not created"
  }

  assert {
    condition = alltrue([
      kubernetes_secret.api_key.data["api_key"] == var.dd_api_key,
      kubernetes_secret.api_key.metadata[0].namespace == var.namespace
    ])
    error_message = "The secret was not created"
  }
}

run "logs_and_discovery" {
  command = plan
  variables {
    logging_enabled = true
    discovered_namespaces = {
      included_namespaces = ["default", "kube-system"]
    }
  }

  assert {
    condition = alltrue([
      yamlencode(kubectl_manifest.agent.yaml_body).spec.features.logCollection.enabled == var.logging_enabled,
    ])
    error_message = "Agent manifest was not properly generated"
  }
}
