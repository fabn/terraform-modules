variable "namespace" {
  description = "The namespace to deploy the rancher application"
  default     = "cattle-system"
  type        = string
}

variable "create_namespace" {
  description = "Whether to create the namespace or not"
  type        = bool
  default     = true
}

variable "release_name" {
  description = "The release name"
  default     = "rancher"
  type        = string
}

# @see https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release#version
variable "chart_version" {
  description = "The version of the chart to deploy, if null on install the latest will be used"
  type        = string
  default     = null
}

variable "resources" {
  description = "The resources to allocate to rancher workloads"
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
      memory = "512Mi"
      cpu    = "100m"
    }
    limits = {
      memory = "512Mi"
    }
  }
}

variable "bootstrap_password" {
  description = "The password to use for the bootstrap admin user"
  type        = string
  default     = null
  nullable    = true
}

variable "hostname" {
  description = "The hostname to configure for rancher"
  type        = string
}


variable "replicas" {
  description = "The number of replicas to deploy"
  type        = number
  default     = 3
}
