variable "name" {
  description = "Name of the context. Must be unique."
  type        = string
}

variable "description" {
  description = "Context description, optional"
  type        = string
  default     = null
}

variable "space_id" {
  description = "Space where to create the context"
  type        = string
  default     = "root"
}

variable "attach_to" {
  description = "List of labels to attach the context to. Every stack with these labels will have access to the context."
  type        = list(string)
  default     = []
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}
