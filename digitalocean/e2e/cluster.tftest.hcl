run "create_cluster" {
  assert {
    condition     = module.e2e_cluster.cluster.cluster.name == "e2e-cluster"
    error_message = "The cluster was not created"
  }
}
