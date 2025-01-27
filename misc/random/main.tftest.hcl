run "test" {
  assert {
    condition     = length(output.uuid) > 0
    error_message = "UUID not generated"
  }
}
