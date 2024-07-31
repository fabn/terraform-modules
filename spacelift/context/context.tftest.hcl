# Stub provider interactions
mock_provider "spacelift" {}

run "create_context" {
  override_data {
    target = data.spacelift_space.root
    values = {
      id = "root"
    }
  }

  variables {
    name = "Test"
    environment_variables = {
      FOO = "bar"
    }
    terraform_variables = {
      foo = "bar"
    }
    attach_to = ["foo", "bar"]
  }

  assert {
    condition     = spacelift_context.context.name == "Test"
    error_message = "The context was not created"
  }

  assert {
    condition     = spacelift_context.context.space_id == "root"
    error_message = "Wrong space ID"
  }

  assert {
    condition     = spacelift_environment_variable.env["FOO"].value == "bar"
    error_message = "Environment variable was not set"
  }

  assert {
    condition     = spacelift_environment_variable.vars["foo"].name == "TF_VAR_foo" && spacelift_environment_variable.vars["foo"].value == "bar"
    error_message = "Terraform variable was not set"
  }

  assert {
    condition     = spacelift_context.context.labels == toset(["autoattach:foo", "autoattach:bar"])
    error_message = "Labels were not set"
  }
}
