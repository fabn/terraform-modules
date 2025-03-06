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
