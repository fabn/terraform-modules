variable "url" {
  description = "The url where to fetch the CRDs"
  type        = string
  validation {
    condition     = can(regex("https?://.*", var.url))
    error_message = "The url must be a valid http or https url"
  }
}
