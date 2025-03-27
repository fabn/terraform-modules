variable "enable_metrics" {
  description = "Enable metrics for the cluster"
  type        = bool
  default     = false
}

variable "prometheus_enabled" {
  description = "Whether to install Prometheus (and enable service monitors) in the cluster"
  type        = bool
  default     = false
}

variable "kind" {
  description = "Whether the cluster is a kind cluster, if so will enable specific values"
  default     = false
  type        = bool
}

variable "digitalocean" {
  description = "Whether the cluster is a digital ocean cluster, if so will enable specific values"
  default     = false
  type        = bool
}

variable "default_ingress" {
  description = "Whether the ingress controller should use the default ingress controller"
  default     = true
  type        = bool
}

variable "load_balancer_hostname" {
  description = "The hostname to use for the load balancer created by nginx ingress (DO only)"
  type        = string
  default     = ""
}

variable "custom_error_pages" {
  description = "Custom error pages to use for the nginx ingress controller"
  type        = bool
  default     = false
}

variable "namespace" {
  default = "ingress-nginx"
  type    = string
}

variable "release_name" {
  default = "ingress-nginx"
  type    = string
}

# @see https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release#version
variable "chart_version" {
  description = "The version of the chart to deploy, if null on install the latest will be used"
  type        = string
  default     = null
}

variable "extra_values" {
  description = "Extra values to pass to the helm chart"
  type        = map(any)
  nullable    = true
  default     = null
}

variable "resources" {
  description = "The resources to allocate to the nginx deployment"
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
      memory = "384Mi"
      cpu    = "50m"
    }
    limits = {
      memory = "384Mi"
    }
  }
}

variable "autoscale" {
  description = "Whether to enable autoscaling for the nginx controller"
  type = object({
    enabled                        = optional(bool),
    minReplicas                    = optional(number),
    maxReplicas                    = optional(number),
    targetCPUUtilizationPercentage = optional(number),
    targetMemoryUtilizationPercentage : optional(number)
  })
  default = {
    enabled                           = true
    minReplicas                       = 1
    maxReplicas                       = 3
    targetCPUUtilizationPercentage    = 600
    targetMemoryUtilizationPercentage = 80
  }
}
