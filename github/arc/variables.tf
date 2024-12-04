variable "github_config_url" {
  description = "GitHub configuration url for this ScaleSet"
  type        = string
  validation {
    condition     = length(var.github_config_url) > 0
    error_message = "GitHub configuration url must be set"
  }
}

variable "scale_set_name_prefix" {
  description = "If given it will generate a random name for the scale sets"
  type        = string
  default     = null
  nullable    = true
}

# See https://github.com/actions/actions-runner-controller/blob/master/charts/gha-runner-scale-set/values.yaml
variable "github_token" {
  sensitive   = true
  description = "GitHub Token to authorize ScaleSet"
  type        = string
  nullable    = true
  default     = null
}

# Alternative to github_token
variable "github_config_secret" {
  sensitive   = true
  description = "GitHub App authentication to authorize runners"
  type = object({
    github_app_id              = string
    github_app_installation_id = string
    github_app_private_key     = string
  })
  nullable = true
  default  = null
}

variable "min_runners" {
  description = "The min number of idle runners"
  default     = 1
  type        = number
}

variable "max_runners" {
  description = "The max number of runners the autoscaling runner set will scale up to."
  default     = 10
  type        = number
}

variable "controller_namespace" {
  description = "The namespace where to install the controller chart"
  type        = string
  default     = "arc-system"
}

variable "controller_version" {
  description = "The version of the controller chart to install (null means latest version)"
  default     = null
  nullable    = true
}


variable "controller_override_values" {
  description = "Controller additional values in YAML format"
  type        = string
  default     = ""
}

variable "runners_namespace" {
  description = "The namespace where to install the runners chart"
  type        = string
  default     = "arc-runners"
}

variable "runners_version" {
  description = "The version of the scale-set chart to install (null means latest version)"
  default     = null
  nullable    = true
}

variable "runners" {
  description = "The runners scale-set to deploy"
  default     = {}
  type = map(object({
    min_runners   = optional(number)
    max_runners   = optional(number)
    runner_group  = optional(string)
    containerMode = optional(string)
    requests = optional(object({
      cpu    = optional(string)
      memory = optional(string)
    }))
    limits = optional(object({
      cpu    = optional(string)
      memory = optional(string)
    }))
    values = optional(string)
  }))
}
