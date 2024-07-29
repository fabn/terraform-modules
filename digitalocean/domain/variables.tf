variable "name" {
  description = "The name of the domain"
  type        = string
  validation {
    condition     = length(var.name) > 0
    error_message = "A domain name must be set"
  }
}

variable "main_records" {
  description = "The records to create for wildcard and root domain"
  type        = map(string)
  default     = {}
}

# @see https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/record
variable "records" {
  description = "Additional records to create"
  type = list(object({
    name  = string
    type  = string # One of A, AAAA, CAA, CNAME, MX, NS, TXT, or SRV
    value = string
    ttl   = optional(number, 3600)
  }))
  default = []
}
