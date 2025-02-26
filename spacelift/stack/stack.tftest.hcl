# Stub provider interactions
mock_provider "spacelift" {}

variables {
  name         = "Test"
  project_root = "/"
  description  = "Test stack"
}

run "simple" {
  assert {
    condition     = spacelift_stack.stack.name == "Test"
    error_message = "The stack was not created"
  }
  assert {
    condition     = spacelift_stack.stack.description == "Test stack"
    error_message = "The stack description was not created"
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
        "FOO"        = "BAR"
      }
    }
  }

  assert {
    condition     = spacelift_stack_dependency.edges["foo"] != null && spacelift_stack_dependency.edges["bar"] != null
    error_message = "Edges were not set"
  }

  assert {
    condition     = contains(output.dependencies, "foo") && contains(output.dependencies, "bar")
    error_message = "Dependencies were not set in output"
  }

  assert {
    condition     = length(keys(output.edges)) == 3 # One for each input => output
    error_message = "Dependency reference was not set"
  }

  assert {
    condition     = spacelift_stack_dependency_reference.edge_content["DB_CONNECTION_STRING@foo => APP_DB_URL@this"].input_name == "TF_VAR_APP_DB_URL"
    error_message = "Dependency reference was not set"
  }

  assert {
    condition = alltrue([
      output.edges["DB_CONNECTION_STRING@foo => APP_DB_URL@this"].stack == "foo",
      output.edges["DB_CONNECTION_STRING@foo => APP_DB_URL@this"].output == "DB_CONNECTION_STRING",
      output.edges["DB_CONNECTION_STRING@foo => APP_DB_URL@this"].input == "APP_DB_URL"
    ])
    error_message = "Dependency reference was not set"
  }
}
