variable "namespace" {
  description = "The namespace where to deploy the application"
  type        = string
}

variable "create_namespace" {
  description = "Whether to create a namespace for the deployment"
  default     = false
  type        = bool
}

variable "name" {
  description = "The name to use for deployment and associated resources"
  type        = string
}

variable "image" {
  description = "The docker image to deploy"
  type        = string
}

variable "replicas" {
  description = "The number of replicas to deploy"
  type        = number
  default     = 1
}

variable "ports" {
  description = "A map of ports to expose"
  type        = map(number)
  default     = {}
}

variable "cpu_requests" {
  description = "The amount of CPU to request"
  type        = string
  default     = null
}

variable "memory_requests" {
  description = "The amount of memory to request"
  type        = string
  default     = null
}

variable "memory_limits" {
  description = "The amount of memory to limit"
  type        = string
  default     = null
}

variable "volumes" {
  description = "A list of volumes to mount"
  type = list(object({
    name       = string
    mount_path = string
    sub_path   = optional(string)
    secret     = optional(string)
    config_map = optional(string)
    mode       = optional(string)
    read_only  = optional(bool)
  }))
  default = []
}

variable "args" {
  description = "The arguments to pass to the container"
  type        = list(string)
  default     = []
}

variable "command" {
  description = "The command to run in the container"
  type        = list(string)
  default     = []
}

variable "config_maps" {
  description = "A list of config maps to mount as environment"
  type        = list(string)
  default     = []
}

variable "env_from" {
  description = "A list of references to mount as environment"
  type = list(object({
    prefix     = optional(string)
    config_map = optional(string)
    secret     = optional(string)
  }))
  default = []
}

variable "pod_annotations" {
  description = "The list of pod annotations to use in template"
  default     = {}
  type        = map(string)
}

variable "secrets" {
  description = "A list of secrets to mount as environment"
  type        = list(string)
  default     = []
}

variable "envs" {
  description = "A map of environment variables to set"
  type        = map(string)
  default     = {}
}

variable "empty_dirs" {
  description = "A list of empty directories to create as memory mounts"
  default     = []
  type        = list(string)
}

variable "http_probe_path" {
  description = "The path to probe for HTTP probes"
  type        = string
  default     = null
  nullable    = true
}

variable "startup_probe_path" {
  description = "The path to probe for startup HTTP probes"
  type        = string
  default     = null
  nullable    = true
}

variable "image_pull_secrets" {
  description = "The name of the image pull secret to use"
  type        = string
  default     = null
  nullable    = true
}

variable "service_type" {
  description = "The type of service to create (if null service will be skipped)"
  default     = "ClusterIP"
  nullable    = true
}

variable "ingress_hostnames" {
  description = "The hostnames to use for the ingress"
  type        = list(string)
  default     = []
}

variable "ingress_annotations" {
  description = "Additional annotations to use for the ingress"
  type        = map(string)
  default     = {}
}

variable "acme_tls" {
  description = "Whether to use ACME TLS for the ingress"
  type        = string
  default     = true
}

variable "env_references" {
  description = "A list of environment references to mount"
  type = list(object({
    name = string
    secret_key_ref = object({
      name     = string
      key      = string
      optional = bool
    })
  }))
  default = []
}

variable "working_dir" {
  description = "The working directory to use for the container"
  type        = string
  default     = null
  nullable    = true
}

variable "service_account_name" {
  description = "The service account to use for the container"
  type        = string
  default     = null
  nullable    = true
}

variable "init_command" {
  description = "The command to run in the init container"
  type = object({
    command = optional(list(string))
    args    = optional(list(string))
    image   = optional(string)
  })
  default = null
}

# Replicates https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_affinities.tpl
variable "anti_affinity" {
  description = "Whether to use anti-affinity for the deployment"
  type        = string
  default     = "soft"
  nullable    = true
  validation {
    condition     = var.anti_affinity == null || can(contains(["soft", "hard"], var.anti_affinity))
    error_message = "Invalid anti-affinity, must be one of soft|hard"
  }
}

variable "create_pdb" {
  description = "Whether to create a pod disruption budget for the deployment"
  type        = bool
  default     = false
}

variable "create_service_monitor" {
  description = "Whether to create a service monitor for the deployment"
  type        = bool
  default     = false
}

variable "dd_tags" {
  description = "The UST tags to apply to all objects sent to Datadog"
  type = object({
    service = optional(string)
    env     = optional(string)
    version = optional(string)
    team    = optional(string)
  })
  default = {}
}

variable "dd_log_tags" {
  description = "Additional tags to add to the logs sent to Datadog"
  type = object({
    container_name = optional(string)
    source         = optional(string)
    service        = optional(string)
    exclude        = optional(list(string), [])
  })
  default = {}
}

variable "dd_checks" {
  description = "Checks to be configured for the container"
  type        = map(any)
  default     = {}
}

variable "dd_check_id" {
  description = "Check ID for builtin Datadog autodiscovery"
  type        = string
  default     = null
  nullable    = true
}
