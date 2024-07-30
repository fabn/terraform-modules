# Stub provider interactions
mock_provider "spacelift" {}

run "create_context" {
  variables {
    project_root = "/"
    name         = "Test"
    secrets = {
      FOO = "bar"
    }
    labels = ["foo", "bar"]
  }

  assert {
    condition     = spacelift_stack.stack.name == "Test"
    error_message = "The stack was not created"
  }

  assert {
    condition     = spacelift_environment_variable.secrets["FOO"].value == "bar"
    error_message = "Environment variable was not set"
  }

  assert {
    condition     = spacelift_stack.stack.labels == toset(["foo", "bar"])
    error_message = "Labels were not set"
  }
}
