variable "cluster_name" {
  description = "The name of the cluster to create for the integration test"
  type        = string
  default     = "e2e-cluster"
  validation {
    condition     = length(var.cluster_name) > 0
    error_message = "A cluster name must be set"
  }
}

variable "domain_name" {
  description = "The name of the domain to associate to the cluster"
  type        = string
  default     = "e2e.fabn.dev"
  validation {
    condition     = length(var.domain_name) > 0
    error_message = "A domain name must be set"
  }
}
