variable "cluster_name" {
  description = "The name of the cluster to report to datadog"
  type        = string
}

variable "namespace" {
  description = "The namespace to install the Datadog helm release"
  type        = string
  default     = "datadog"
}

variable "chart_version" {
  description = "The version of the chart to deploy, if null latest is used"
  type        = string
  default     = null
  nullable    = true
}

variable "dd_api_key" {
  description = "The Datadog API key"
  type        = string
  sensitive   = true
}

variable "dd_site" {
  description = "The Datadog site to use"
  type        = string
  # Check https://docs.datadoghq.com/getting_started/site/
  validation {
    condition = contains([
      "datadoghq.com",
      "datadoghq.eu",
      "us3.datadoghq.com",
      "us5.datadoghq.com",
      "ddog-gov.com",
      "ap1.datadoghq.com"
    ], var.dd_site)
    error_message = "Invalid Datadog site"
  }
}

variable "global_tags" {
  description = "Global env tag set for datadog integrations"
  type        = map(string)
  default     = {}
}

# Discovery options
# see: https://docs.datadoghq.com/containers/guide/container-discovery-management/?tab=datadogoperator
variable "discovered_namespaces" {
  description = "Tune the discovery of pods to monitor and collect logs from"
  # Can be lists of strings or regex that matches namespaces
  type = object({
    included_namespaces = optional(list(string))
    excluded_namespaces = optional(list(string))
  })
  default = {
    included_namespaces = []
    excluded_namespaces = []
  }
}

# see: https://docs.datadoghq.com/containers/kubernetes/log/?tab=datadogoperator
variable "logging_enabled" {
  description = "Whether to enable logging collection for the cluster"
  type        = bool
  default     = false
}

# see: https://docs.datadoghq.com/containers/kubernetes/log/?tab=datadogoperator
# If false, you should fine tune logging using pod annotations
# Keep in mind that even if this is set to true, it still respects settings given in inclusion and exclusion rules
variable "collect_all_logging" {
  description = "Whether to collect all logs from the cluster"
  type        = bool
  default     = true
}

variable "extra_values" {
  description = "Extra values to pass to the operator helm chart"
  type        = any # This must be any otherwise terraform will complain about the type
  nullable    = true
  default     = null
}

# This is a YAML fragment that will be passed to the operator helm chart as is
variable "extra_yaml" {
  description = "Extra YAML fragment to pass to the operator helm chart"
  type        = string
  nullable    = true
  default     = null
}

# This is a generic object that will be passed to the DatadogAgent manifest
variable "datadog_agent_overrides" {
  description = "Extra values passed to the DatadogAgent manifest in override field"
  type        = any
  nullable    = true
  default     = {}
}
