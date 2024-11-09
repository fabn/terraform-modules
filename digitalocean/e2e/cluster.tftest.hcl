run "create_cluster" {
  variables {
    cluster_name = "e2e-test"
  }
  assert {
    condition     = module.e2e_cluster.cluster.cluster.name == "e2e-test"
    error_message = "The cluster was not created"
  }
}
