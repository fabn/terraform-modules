locals {
  stack_dependencies = [for k, v in var.dependencies : nonsensitive(k)]

  # Create a set of keys for each dependency and stack
  dependencies_map = flatten([
    for stack, values in var.dependencies : [
      for key, value in values : {
        stack  = stack
        input  = value
        output = key
      }
    ]
  ])

  # Build a map that represent the dependencies we're building between stacks
  input_output_maps = tomap({
    for entry in local.dependencies_map : "${entry.output}@${entry.stack} => ${entry.input}@this"
    => entry
  })
}

# Stack dependencies, if any
resource "spacelift_stack_dependency" "edges" {
  for_each            = nonsensitive(var.dependencies)
  stack_id            = spacelift_stack.stack.id
  depends_on_stack_id = each.key
}

resource "spacelift_stack_dependency_reference" "edge_content" {
  for_each            = local.input_output_maps
  stack_dependency_id = spacelift_stack_dependency.edges[each.value.stack].id
  output_name         = each.value.output
  input_name          = "TF_VAR_${each.value.input}"
}
