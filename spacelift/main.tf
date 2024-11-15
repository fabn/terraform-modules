terraform {
  required_providers {
    spacelift = {
      source = "spacelift-io/spacelift"
    }
  }
}

data "spacelift_space" "root" {
  space_id = "root"
}

data "spacelift_stack" "newrelic" {
  stack_id = "newrelic"
}

data "spacelift_stack" "do" {
  stack_id = "motohelp-digitalocean"
}

module "test" {
  source       = "./stack"
  name         = "Test"
  repository   = "terraform"
  project_root = "test"
  dependencies = {
    (data.spacelift_stack.newrelic.id) = {
      "NR_key" = "NR_LICENSE_KEY"
    }
    (data.spacelift_stack.do.id) = {
      "APP_DB_URL" = "DB_CONNECTION_STRING"
      "FOO"        = "BAR"
    }
  }
}

output "stack_id" {
  value = module.test.stack_id
}

output "stack" {
  sensitive = true
  value     = module.test.stack
}

output "dependencies" {
  value = module.test.dependencies
}

output "edges" {
  value = module.test.edges
}
