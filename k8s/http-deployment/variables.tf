variable "name" {
  description = "Basename, used to build resources. Must be unique."
  type        = string
}

variable "ingress_hostname" {
  description = "The hostname to use for the ingress"
  type        = string
}

variable "namespace" {
  description = "The namespace to deploy the deployment and service"
  type        = string
}

variable "create_namespace" {
  description = "Whether to create the namespace"
  type        = bool
  default     = true
}

variable "tls_hosts" {
  description = "The hosts to use for the TLS certificate"
  type        = list(string)
  default     = []
}

variable "image" {
  description = "The image to deploy"
  type        = string
}

variable "port" {
  description = "The port the container exposes"
  type        = number
  default     = 80
}

variable "startup_probe_endpoint" {
  description = "The endpoint to probe on startup"
  type        = string
  default     = "/"
}

variable "ingress_class_name" {
  description = "Ingress class to use"
  type        = string
  default     = null
}
