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

# Passed for tests, not used in the module directly
variable "do_token" {
  description = "DigitalOcean API token, used to query the load balancer IP"
  type        = string
  default     = null
  sensitive   = true
  nullable    = true
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
