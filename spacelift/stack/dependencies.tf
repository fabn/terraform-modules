locals {
  stack_dependencies = [for k, v in var.dependencies : nonsensitive(k)]
}

# Stack dependencies, if any
resource "spacelift_stack_dependency" "edges" {
  for_each            = nonsensitive(var.dependencies)
  stack_id            = spacelift_stack.stack.id
  depends_on_stack_id = each.key
}

/*resource "spacelift_stack_dependency_reference" "dependencies" {
  for_each = var.dependencies_map != null ? toset(keys(var.dependencies_map)) : toset([])
  stack_dependency_id = spacelift_stack_dependency.dependencies.id
  output_name         = "DB_CONNECTION_STRING"
  input_name          = "APP_DB_URL"
}
*/
