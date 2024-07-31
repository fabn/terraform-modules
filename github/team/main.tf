terraform {
  required_providers {
    github = {
      source = "integrations/github"
    }
  }
}

variable "name" {
  description = "The name of the team"
  type        = string
}

variable "description" {
  description = "The description of the team"
  type        = string
  default     = null
}

variable "members" {
  description = "The list of users to add to the team as members"
  type        = list(string)
  default     = []
}

variable "maintainers" {
  description = "The list of users to add to the team as maintainers"
  type        = list(string)
  default     = []
}

variable "repos" {
  description = "Permissions to assign to the repositories for the team"
  type        = map(string)
  default     = {}
}

resource "github_team" "team" {
  name        = var.name
  description = var.description
  privacy     = "closed"
}

# Add users to the team as members
resource "github_team_members" "users" {
  # If no members provided skip this resource entirely
  count   = length(var.members) + length(var.maintainers) > 0 ? 1 : 0
  team_id = github_team.team.id
  dynamic "members" {
    for_each = toset(var.members)
    content {
      username = members.value
      role     = "member"
    }
  }

  dynamic "members" {
    for_each = toset(var.maintainers)
    content {
      username = members.value
      role     = "maintainer"
    }
  }
}

resource "github_team_repository" "permissions" {
  for_each   = var.repos
  team_id    = github_team.team.id
  repository = each.key
  permission = each.value
}

output "team" {
  value = github_team.team
}
