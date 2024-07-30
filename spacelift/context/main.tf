terraform {
  required_providers {
    spacelift = {
      source = "spacelift-io/spacelift"
    }
  }
}

data "spacelift_space" "root" {
  space_id = var.space_id
}

resource "spacelift_context" "context" {
  name        = var.name
  description = var.description
  labels      = [for label in var.attach_to : "autoattach:${label}"]
  space_id    = data.spacelift_space.root.id
}

resource "spacelift_environment_variable" "env" {
  for_each   = toset(keys(var.environment_variables))
  context_id = spacelift_context.context.id
  name       = each.key
  value      = var.environment_variables[each.key]
  write_only = true
}

resource "spacelift_environment_variable" "vars" {
  for_each   = toset(keys(var.terraform_variables))
  context_id = spacelift_context.context.id
  name       = "TF_VAR_${each.key}"
  value      = var.terraform_variables[each.key]
  write_only = true
}
