variables {
  container_name = "demo"
}

run "default" {
  assert {
    condition     = var.container_name == "demo"
    error_message = "Container name should be 'demo'"
  }

  assert {
    condition     = output.tags == null
    error_message = "Tags are empty with no values passed"
  }

  assert {
    condition     = output.annotations == null
    error_message = "Annotations should be null with no values passed"
  }

  assert {
    condition     = output.logs_annotation_key == "ad.datadoghq.com/demo.logs"
    error_message = "Annotation key should be 'ad.datadoghq.com/demo.logs'"
  }
}

run "with_source_and_service" {
  variables {
    container_name = "demo"
    log_source     = "demo-source"
    service        = "demo-service"
  }

  assert {
    condition     = output.tags.source == "demo-source"
    error_message = "Log source tag should be 'demo-source'"
  }

  assert {
    condition     = output.tags.service == "demo-service"
    error_message = "Service tag should be 'demo-service'"
  }

  assert {
    condition = output.annotations["ad.datadoghq.com/demo.logs"] == jsonencode([{
      source  = "demo-source"
      service = "demo-service"
    }])
    error_message = "No log processing rules should be set"
  }

}

run "with_exclusions" {
  variables {
    exclude = ["/error", "debug"]
  }

  assert {
    condition     = length(output.tags["log_processing_rules"]) == 2
    error_message = "There should be two log processing rules"
  }

  assert {
    condition     = output.tags["log_processing_rules"][0].type == "exclude_at_match"
    error_message = "First log processing rule should be 'exclude_at_match'"
  }

  assert {
    condition     = output.tags["log_processing_rules"][0].name == "exclude--error"
    error_message = "First log processing rule name should be 'exclude--error'"
  }

  assert {
    condition     = output.tags["log_processing_rules"][0].pattern == "/error"
    error_message = "First log processing rule should exclude '/error'"
  }
}

run "full" {
  variables {
    log_source = "demo-source"
    service    = "demo-service"
    exclude    = ["/error", "debug"]
  }

  assert {
    condition     = output.tags.source == "demo-source"
    error_message = "Log source tag should be 'demo-source'"
  }
}
