terraform {
  required_providers {
    terracurl = {
      source = "devops-rob/terracurl"
    }
  }
}

variable "url" {
  description = "The url to test"
}

variable "method" {
  description = "HTTP method"
  default     = "GET"
}

variable "description" {
  description = "Optional description of the request"
  default     = "Http request"
}

variable "status_codes" {
  description = "List of expected status codes to validate"
  type        = list(number)
  default     = [200]
}

variable "skip_tls_verify" {
  description = "Whether to skip SSL certificate validation"
  type        = bool
  default     = false
}

variable "max_retry" {
  description = "Maximum number of retries"
  type        = number
  default     = 3
}

variable "retry_interval" {
  description = "Interval between retries in seconds"
  type        = number
  default     = 5
}

# Perform a curl request against deployed service
resource "terracurl_request" "curl" {
  url             = var.url
  method          = var.method
  name            = var.description
  response_codes  = var.status_codes
  skip_tls_verify = var.skip_tls_verify
  # Wait for the service to be available up to 15 seconds
  max_retry      = var.max_retry
  retry_interval = var.retry_interval
}

output "curl" {
  description = "The full object"
  value       = terracurl_request.curl
}

output "status_code" {
  description = "HTTP status code"
  value       = tonumber(terracurl_request.curl.status_code)
}

output "response_body" {
  description = "Request response body"
  value       = terracurl_request.curl.response
}
