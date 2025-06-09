locals {
  # Used for builtin checks by integration ID
  checks_id_annotation_key = "ad.datadoghq.com/${var.container_name}.check.id"

  annotations_map = merge(
    local.has_tags ? {
      (local.logs_annotation_key) : local.json_log_configuration
    } : {},
    local.has_checks ? {
      (local.checks_annotation_key) : local.json_checks_configuration
    } : {},
    var.check_id != null ? {
      (local.checks_id_annotation_key) = var.check_id
    } : {}
  )

  # Final container annotations
  annotations = length(keys(local.annotations_map)) > 0 ? local.annotations_map : null
}
