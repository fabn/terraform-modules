variable "container_name" {
  description = "Name of kubernetes container to generate log tag for"
  type        = string
}

variable "log_source" { # Source is a reserved name
  description = "Log source tag"
  type        = string
  default     = null
  nullable    = true
}

variable "service" {
  description = "Datadog log name"
  type        = string
  default     = null
  nullable    = true
}

variable "exclude" {
  description = "List of exclusion patterns"
  type        = list(string)
  default     = []
}

variable "checks" {
  description = "Checks to be configured for the container"
  type        = map(any)
  default     = {}
}

variable "check_id" {
  # see https://docs.datadoghq.com/containers/guide/ad_identifiers/?tab=kubernetesannotation#custom-autodiscovery-container-identifiers
  description = "Check ID to be used in the annotations"
  type        = string
  default     = null
  nullable    = true
}
