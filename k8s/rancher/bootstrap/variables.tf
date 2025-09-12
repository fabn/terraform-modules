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
