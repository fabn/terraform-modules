# Input variable passed to module
variable "default_cluster_issuer" {
  description = "The name of the default cluster issuer, if null it will be skipped"
  default     = "letsencrypt-cluster-issuer"
  type        = string
  nullable    = true
}

variable "production" {
  description = "Whether to use the production letsencrypt issuer or the staging issuer"
  default     = false
  type        = bool
}

variable "letsencrypt_email" {
  type      = string
  sensitive = true
  nullable  = true
  default   = null
}

variable "namespace" {
  default = "cert-manager"
  type    = string
}

variable "create_namespace" {
  description = "Whether to create the namespace"
  type        = bool
  default     = true
}

variable "release_name" {
  default = "cert-manager"
  type    = string
}

variable "chart_version" {
  description = "The version of the chart to deploy, used to install chart and relative CRDs"
  type        = string
}

variable "do_token" {
  description = "DigitalOcean API token used in dns solver"
  type        = string
  sensitive   = true
  default     = null
}
