output "tags" {
  description = "The tags used in the container logging"
  value       = local.has_tags ? local.tags : null
}

output "checks" {
  description = "The checks configuration for the container"
  value       = local.has_checks ? local.checks_configuration : null
}

output "logs_annotation_key" {
  description = "The annotation key for the container logs"
  value       = local.logs_annotation_key
}

output "checks_annotation_key" {
  description = "The annotation key for the container checks"
  value       = local.checks_annotation_key
}

output "json_log_configuration" {
  description = "Raw JSON log configuration for the container"
  value       = local.json_log_configuration
}

output "json_checks_configuration" {
  description = "Raw JSON checks configuration for the container"
  value       = local.json_checks_configuration
}

output "annotations" {
  description = "The full annotation object"
  value       = local.annotations
}
