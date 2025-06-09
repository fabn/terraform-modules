locals {
  checks_annotation_key = "ad.datadoghq.com/${var.container_name}.checks"

  checks_configuration = {
    for check_name, check in var.checks : check_name => {
      # Default instance configuration if not provided
      init_config = lookup(check, "init_config", {})
      instances   = lookup(check, "instances", [])
    }
  }

  json_checks_configuration = jsonencode(local.checks_configuration)

  has_checks = length(keys(local.checks_configuration)) > 0
}
