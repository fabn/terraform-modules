variable "bootstrap_password" {
  description = "The password to use for bootstrapping rancher, pass this only to import existing installations"
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "The password to use for the admin user"
  type        = string
  default     = null
  nullable    = true
  sensitive   = true
}

variable "token_update" {
  description = "Whether to update the token on each apply when expired"
  type        = bool
  default     = true
}
