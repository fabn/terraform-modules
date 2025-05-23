terraform {
  required_providers {
    github = {
      source = "integrations/github"
    }
  }
}

variable "name" {
  description = "The name of the repository"
  type        = string
}

variable "description" {
  description = "The description of the repository"
  type        = string
  default     = null
}

variable "default_branch" {
  description = "The default branch name"
  type        = string
  default     = "main"
}

variable "homepage_url" {
  description = "The homepage of the repository"
  type        = string
  default     = null
}

variable "has_issues" {
  description = "Whether the repository has issues enabled"
  type        = bool
  default     = true
}

variable "has_projects" {
  description = "Whether the repository has issues enabled"
  type        = bool
  default     = true
}

variable "has_dependabot" {
  description = "Whether the repository has issues enabled"
  type        = bool
  default     = false
}

variable "secrets" {
  type      = map(string)
  default   = {}
  sensitive = true
}

variable "dependabot_secrets" {
  type      = map(string)
  default   = {}
  sensitive = true
}

variable "variables" {
  description = "A map of variables to configure in the repository (global secrets)"
  type        = map(string)
  default     = {}
  sensitive   = false
}

variable "auto_init" {
  description = "Set to true when creating new repositories"
  default     = true
  type        = bool
}

variable "shared_workflows" {
  description = "Whether the repository shares workflows"
  type        = bool
  default     = false
}

variable "teams" {
  description = "The teams to add to the repository"
  type        = map(string)
  default     = {}
}

variable "archived" {
  description = "Whether the repository is archived"
  type        = bool
  default     = false
}

variable "archive_on_destroy" {
  description = "Whether the repository should be archived on destroy"
  type        = bool
  default     = false
}

variable "visibility" {
  description = "The visibility of the repository"
  default     = "private"
  type        = string
}

variable "allow_auto_merge" {
  description = "Whether to allow auto merge"
  type        = bool
  default     = true
}

resource "github_repository" "repo" {
  name                        = var.name
  description                 = var.description
  homepage_url                = var.homepage_url
  visibility                  = var.visibility
  allow_auto_merge            = var.allow_auto_merge
  allow_merge_commit          = false
  allow_rebase_merge          = false
  allow_update_branch         = true
  delete_branch_on_merge      = true
  has_downloads               = false
  has_issues                  = var.has_issues
  has_projects                = var.has_projects
  squash_merge_commit_message = "BLANK"
  squash_merge_commit_title   = "PR_TITLE"
  vulnerability_alerts        = var.has_dependabot
  auto_init                   = var.auto_init
  archived                    = var.archived
  archive_on_destroy          = var.archive_on_destroy
  # Ensure repositories are never deleted via terraform
  lifecycle {
    prevent_destroy = true
  }
}

data "github_branch" "default" {
  count      = var.default_branch != null ? 1 : 0
  repository = github_repository.repo.name
  branch     = var.default_branch
}

resource "github_branch_default" "default" {
  count      = var.default_branch != null ? 1 : 0
  repository = github_repository.repo.name
  branch     = data.github_branch.default[0].branch
}


# Configure a secret for each passed value
resource "github_actions_secret" "secrets" {
  for_each        = nonsensitive(var.secrets)
  repository      = github_repository.repo.name
  secret_name     = each.key
  plaintext_value = each.value
}

# Secrets for repository
resource "github_dependabot_secret" "secrets" {
  for_each        = nonsensitive(var.dependabot_secrets)
  repository      = github_repository.repo.name
  secret_name     = each.key
  plaintext_value = each.value
}


# Configure a variable for each passed value (non sensitive)
resource "github_actions_variable" "variables" {
  for_each      = var.variables
  repository    = github_repository.repo.name
  variable_name = each.key
  value         = each.value
}

# Expose workflow files to other repositories in our organization
# @see https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository#managing-access-for-a-private-repository-in-an-organization
resource "github_actions_repository_access_level" "shared_workflow_access" {
  count        = var.shared_workflows ? 1 : 0
  access_level = "organization"
  repository   = github_repository.repo.name
}

# Manage team permissions if specified
data "github_team" "team" {
  for_each = var.teams
  slug     = each.key
}

resource "github_team_repository" "team_permissions" {
  for_each   = var.teams
  team_id    = data.github_team.team[each.key].id
  repository = github_repository.repo.name
  permission = each.value
}

output "repository" {
  value = github_repository.repo
}
