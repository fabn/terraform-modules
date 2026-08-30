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
  type = object({
    wildcard = optional(string)
    root     = optional(string)
    # Shared by both records rather than one each: they are what a consumer
    # lowers together before repointing a zone, so that resolvers stop handing
    # out the old answer within the new TTL rather than the old one.
    ttl = optional(number, 1800)
  })
  default = {}
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
