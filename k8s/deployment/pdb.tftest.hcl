variables {
  create_namespace = true
  # These are the minimal requirements to have a deployment using this module
  name       = "echo"
  namespace  = "deployment-test"
  image      = "ealen/echo-server:latest"
  create_pdb = true
}

run "with_pdb" {
  assert {
    condition     = kubernetes_pod_disruption_budget_v1.pdb[0].metadata[0].name == "echo-pdb"
    error_message = "Uses the proper name"
  }

  assert {
    condition     = kubernetes_pod_disruption_budget_v1.pdb[0].spec[0].max_unavailable == "1"
    error_message = "Configures the max_unavailable"
  }

  assert {
    condition = alltrue([
      kubernetes_pod_disruption_budget_v1.pdb[0].metadata.0.labels == tomap(output.labels),
      kubernetes_pod_disruption_budget_v1.pdb[0].spec.0.selector.0.match_labels == tomap(output.labels),
    ])
    error_message = "Labels are not set on pdb"
  }
}
