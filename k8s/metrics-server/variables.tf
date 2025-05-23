variable "namespace" {
  default = "metrics-server"
  type    = string
}

variable "create_namespace" {
  description = "Whether to create the namespace or not"
  type        = bool
  default     = true
}

variable "release_name" {
  default = "metrics-server"
  type    = string
}

variable "kind" {
  description = "Whether the cluster is a kind cluster, if so will enable specific values"
  default     = false
  type        = bool
}

# @see https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release#version
variable "chart_version" {
  description = "The version of the chart to deploy, if null on install the latest will be used"
  type        = string
  default     = null
}

variable "metrics_enabled" {
  description = "Enable metrics collection"
  type        = bool
  default     = true
}

variable "service_monitor_enabled" {
  description = "Enable service monitor"
  type        = bool
  default     = false
}

variable "resources" {
  description = "The resources to allocate to the metrics server"
  type = object({
    requests = optional(object({
      memory = optional(string)
      cpu    = optional(string)
    })),
    limits = optional(object({
      memory = optional(string)
      cpu    = optional(string)
    }))
  })
  default = {
    requests = {
      memory = "100Mi"
      cpu    = "10m"
    }
    limits = {
      memory = "100Mi"
    }
  }
}
