# Full E2E test in a single module that setups everything
run "create_cluster" {
  variables {
    name   = "e2e-full"
    region = "fra1"
  }
  assert {
    condition     = output.cluster_name == "e2e-full"
    error_message = "The cluster was not created"
  }
}
