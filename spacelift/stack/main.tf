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

resource "spacelift_stack" "stack" {
  name                            = var.name
  space_id                        = data.spacelift_space.root.id
  repository                      = var.repository
  branch                          = var.branch
  administrative                  = var.administrative
  labels                          = var.labels
  project_root                    = var.project_root
  autodeploy                      = var.autodeploy
  terraform_smart_sanitization    = true
  terraform_external_state_access = true
  enable_local_preview            = true
  protect_from_deletion           = true
  terraform_version               = "1.5.7"
  terraform_workflow_tool         = "TERRAFORM_FOSS"
  runner_image                    = var.runner_image
}

resource "spacelift_environment_variable" "secrets" {
  stack_id   = spacelift_stack.stack.id
  for_each   = nonsensitive(var.secrets)
  name       = each.key
  value      = each.value
  write_only = true
}
