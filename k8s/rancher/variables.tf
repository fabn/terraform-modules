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
  description = "The password to use for bootstrapping rancher, pass this only to import existing installations"
  type        = string
  default     = null
  nullable    = true
}

variable "admin_password" {
  description = "The password to use for the admin user"
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

variable "ingress_class_name" {
  description = "The name of the ingress class to use"
  type        = string
  default     = null
  nullable    = true
}

variable "extra_values" {
  description = "Extra values to pass to the helm chart"
  type        = map(any)
  nullable    = true
  default     = null
}

variable "self_signed" {
  description = "Whether to use self signed certificates or not"
  type        = bool
  default     = false
}
