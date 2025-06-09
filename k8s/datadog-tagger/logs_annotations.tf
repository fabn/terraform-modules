
locals {
  logs_annotation_key = "ad.datadoghq.com/${var.container_name}.logs"

  exclusion_rules = [
    for pattern in coalesce(var.exclude, []) : {
      type    = "exclude_at_match",
      name    = "exclude-${replace(pattern, "/\\W+/", "-")}",
      pattern = pattern
    }
  ]

  log_processing_rules = length(local.exclusion_rules) > 0 ? {
    log_processing_rules : local.exclusion_rules
  } : {}

  log_configuration = {
    source  = var.log_source
    service = var.service
  }

  tags = merge(
    { for k, v in local.log_configuration : k => v if !(v == null) },
    local.log_processing_rules
  )

  json_log_configuration = jsonencode([local.log_configuration])

  has_tags = length(keys(local.tags)) > 0
}
