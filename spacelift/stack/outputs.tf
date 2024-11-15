output "stack" {
  description = "The full stack object"
  value       = spacelift_stack.stack
  sensitive   = true
}

output "stack_id" {
  description = "Managed stack identifier"
  value       = spacelift_stack.stack.id
}

output "dependencies" {
  description = "The list of stacks this stack depends on"
  value       = local.stack_dependencies
}

output "edges" {
  description = "Content of the edges as map"
  value       = local.input_output_maps
}
