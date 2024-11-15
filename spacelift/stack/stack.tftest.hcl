# Stub provider interactions
mock_provider "spacelift" {}

variables {
  name         = "Test"
  project_root = "/"
}

run "simple" {
  assert {
    condition     = spacelift_stack.stack.name == "Test"
    error_message = "The stack was not created"
  }
  assert {
    condition     = output.stack_id == spacelift_stack.stack.id
    error_message = "Stack ID was not set as output"
  }
}

run "create_context" {
  override_data {
    target = data.spacelift_space.root
    values = {
      id = "root"
    }
  }

  variables {
    secrets = {
      FOO = "bar"
    }
    labels = ["foo", "bar"]
    terraform_variables = {
      bar = "baz"
    }
  }

  assert {
    condition     = spacelift_stack.stack.name == "Test"
    error_message = "The stack was not created"
  }

  assert {
    condition     = spacelift_stack.stack.space_id == "root"
    error_message = "Wrong space ID"
  }

  assert {
    condition     = spacelift_environment_variable.secrets["FOO"].value == "bar"
    error_message = "Environment variable was not set"
  }

  assert {
    condition     = spacelift_environment_variable.vars["bar"].value == "baz"
    error_message = "Environment variable was not set"
  }

  assert {
    condition     = spacelift_stack.stack.labels == toset(["foo", "bar"])
    error_message = "Labels were not set"
  }
}

run "with_dependencies" {
  variables {
    dependencies = {
      "foo" = {
        "DB_CONNECTION_STRING" = "APP_DB_URL"
      }
      "bar" = {
        "APP_DB_URL" = "DB_CONNECTION_STRING"
      }
    }
  }

  assert {
    condition     = spacelift_stack_dependency.edges["foo"] != null && spacelift_stack_dependency.edges["bar"] != null
    error_message = "Edges were not set"
  }

  assert {
    condition     = contains(output.stack_edges, "foo") && contains(output.stack_edges, "bar")
    error_message = "Dependencies were not set in output"
  }
}
