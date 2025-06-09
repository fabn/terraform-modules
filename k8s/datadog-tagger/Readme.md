# Datadog Tagger Terraform Module

This Terraform module is designed to generate annotations for Kubernetes containers to configure Datadog integrations.
It supports both log and check configurations, allowing you to define custom checks, log sources, services, and
exclusion rules.

## Features

- Generate annotations for Datadog checks and logs.
- Support for custom checks with `init_config` and `instances`.
- Built-in support for log source, service, and exclusion rules.
- Flexible configuration for both checks and logs.

## Usage

```hcl
module "datadog_tagger" {
  source = "./k8s/datadog-tagger"

  container_name = "demo"
  log_source     = "demo-source"
  service        = "demo-service"
  exclude        = ["/error", "debug"]
  checks = {
    apache = {
      instances = [{
        status_url = "http://localhost/server-status?auto"
      }]
    }
  }
}
```

## Inputs

| Name             | Description                                           | Type           | Default | Required |
|------------------|-------------------------------------------------------|----------------|---------|----------|
| `container_name` | Name of the Kubernetes container to generate tags for | `string`       | n/a     | yes      |
| `log_source`     | Log source tag                                        | `string`       | `null`  | no       |
| `service`        | Datadog log name                                      | `string`       | `null`  | no       |
| `exclude`        | List of exclusion patterns                            | `list(string)` | `[]`    | no       |
| `checks`         | Checks to be configured for the container             | `map(any)`     | `{}`    | no       |
| `check_id`       | Check ID to be used in the annotations                | `string`       | `null`  | no       |

## Outputs

| Name                        | Description                                     |
|-----------------------------|-------------------------------------------------|
| `tags`                      | The tags used in the container logging          |
| `checks`                    | The checks configuration for the container      |
| `logs_annotation_key`       | The annotation key for the container logs       |
| `checks_annotation_key`     | The annotation key for the container checks     |
| `json_log_configuration`    | Raw JSON log configuration for the container    |
| `json_checks_configuration` | Raw JSON checks configuration for the container |
| `annotations`               | The full annotation object                      |

## Examples

### Default Configuration

```hcl
module "datadog_tagger" {
  source         = "./k8s/datadog-tagger"
  container_name = "demo"
}
```

### Full Configuration

```hcl
module "datadog_tagger" {
  source         = "./k8s/datadog-tagger"
  container_name = "demo"
  log_source     = "demo-source"
  service        = "demo-service"
  exclude = ["/error", "debug"]
  checks = {
    apache = {
      instances = [
        {
          status_url = "http://localhost/server-status?auto"
        }
      ]
    }
  }
}
```

## Testing

This module includes test cases written in `.tftest.hcl` files to validate its behavior. Use the following command to
run the tests:

```bash
terraform test
```
