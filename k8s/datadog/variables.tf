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
  default = "datadoghq.com" # US1
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
