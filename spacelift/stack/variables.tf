variable "name" {
  description = "Name of the stack bucket. Must be unique."
  type        = string
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

variable "administrative" {
  description = "Whether the stack should have administrative privileges."
  type        = bool
  default     = false
}

variable "runner_image" {
  description = "Custom runner image"
  type        = string
  default     = null
  # e.g. "fabn/runner-terraform:v1.8.1"
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

variable "dependencies" {
  description = "Map of dependencies from other stacks"
  type        = map(map(string))
  default     = {}
}
