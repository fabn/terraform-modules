mock_provider "github" {}

variables {
  name         = "some-repo"
  description  = "Repository description"
  homepage_url = "https://example.com"
}

run "create_repo" {
  assert {
    condition     = output.repository.name == "some-repo"
    error_message = "The repo was not created"
  }
}

run "create_repo_with_secrets" {
  variables {
    secrets = {
      FOO = "bar"
    }
  }

  assert {
    condition     = github_actions_secret.secrets["FOO"].plaintext_value == "bar"
    error_message = "The secret was not created"
  }
}

run "create_repo_with_workflow_access" {
  variables {
    shared_workflows = true
  }

  assert {
    condition     = length(github_actions_repository_access_level.shared_workflow_access) == 1
    error_message = "The access was not created"
  }
}

run "create_repo_with_team_access" {
  variables {
    teams = {
      "some-team" = "admin"
    }
  }

  assert {
    condition     = github_team_repository.team_permissions["some-team"].permission == "admin"
    error_message = "The team grants was not created"
  }
}
