# Full E2E test in a single module that setups everything
run "full_cluster" {
  assert {
    condition     = output.base_domain != null
    error_message = "A basedomain was not created"
  }
}
