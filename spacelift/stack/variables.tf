variable "name" {
  description = "Name of the stack bucket. Must be unique."
  type        = string
}

variable "description" {
  description = "Stack description"
  type        = string
  default     = null
}

variable "slug" {
  description = "Slug of the stack. When null the provider derives it from the stack name."
  type        = string
  default     = null
}

variable "space_id" {
  description = "Space where to create the context"
  type        = string
  default     = "root"
}

variable "repository" {
  description = "Region where the stack bucket will be created."
  type        = string
  default     = "terraform"
}

variable "branch" {
  description = "Repository branch to use."
  type        = string
  default     = "main"
}

variable "project_root" {
  description = "Path to the root of the project."
  type        = string
}

variable "additional_project_globs" {
  description = "Paths to track changes of in addition to the project root."
  type        = set(string)
  default     = null
}

variable "administrative" {
  description = "Whether the stack should have administrative privileges, granted by attaching the Space Admin role on the stack's own space."
  type        = bool
  default     = false
}

variable "runner_image" {
  description = "Custom runner image"
  type        = string
  default     = null
  # e.g. "fabn/runner-terraform:v1.8.1"
}

variable "terraform_version" {
  description = "Terraform version used by the managed stack. Defaults to the last MPL licensed release, which Spacelift default runner images ship."
  type        = string
  default     = "1.5.7"
}

variable "protect_from_deletion" {
  description = "Whether the stack is protected from deletion. Set to false to retire the stack."
  type        = bool
  default     = true
}

variable "enable_sensitive_outputs_upload" {
  description = "Whether sensitive outputs are uploaded so dependent stacks can consume them. When null the provider default applies."
  type        = bool
  default     = null
}

variable "labels" {
  description = "Labels to apply to the stack."
  type        = list(string)
  default     = []
}

variable "autodeploy" {
  description = "Whether the stack should be automatically deployed."
  type        = bool
  default     = true
}

variable "secrets" {
  type      = map(string)
  default   = {}
  sensitive = true
}

variable "terraform_variables" {
  type      = map(string)
  default   = {}
  sensitive = true
}

variable "namespace" {
  description = "GitHub org/user owner of the repository. When set, a github_enterprise block is used instead of the default integration."
  type        = string
  default     = null
}

variable "dependencies" {
  description = "Map of dependencies from other stacks"
  type        = map(map(string))
  default     = {}
}
