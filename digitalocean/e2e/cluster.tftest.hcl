run "create_cluster" {
  assert {
    condition     = output.cluster.name == "e2e-cluster"
    error_message = "The cluster was not created"
  }
}
