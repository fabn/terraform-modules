output "stack" {
  description = "The full stack object"
  value       = spacelift_stack.stack
  sensitive   = true
}

output "stack_id" {
  description = "Managed stack identifier"
  value       = spacelift_stack.stack.id
}

output "stack_edges" {
  value = local.stack_dependencies
}
