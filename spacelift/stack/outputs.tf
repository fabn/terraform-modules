output "stack_id" {
  description = "Managed stack identifier"
  value       = spacelift_stack.stack.id
}

output "cross_stack_variables" {
  description = "Cross-stack variables"
  value = {

  }
}
