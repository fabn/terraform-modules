mock_provider "github" {}

variables {
  name         = "some-repo"
  description  = "Repository description"
  homepage_url = "https://example.com"
}

run "create_repo" {
  command = plan
  assert {
    condition     = output.repository.name == "some-repo"
    error_message = "The repo was not created"
  }

  assert {
    condition     = github_branch_default.default[0].branch == var.default_branch
    error_message = "Default branch was not set"
  }
}

run "create_repo_with_secrets" {
  command = plan
  variables {
    secrets = {
      FOO = "bar"
    }
    dependabot_secrets = {
      FOO = "baz"
    }
  }

  assert {
    condition     = github_actions_secret.secrets["FOO"].plaintext_value == "bar"
    error_message = "The secret was not created"
  }
  assert {
    condition     = github_dependabot_secret.secrets["FOO"].plaintext_value == "baz"
    error_message = "The secret was not created"
  }
}

run "create_repo_with_workflow_access" {
  command = plan
  variables {
    shared_workflows = true
  }

  assert {
    condition     = length(github_actions_repository_access_level.shared_workflow_access) == 1
    error_message = "The access was not created"
  }
}

run "create_repo_with_team_access" {
  command = plan
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

run "create_repo_with_variables" {
  command = plan
  variables {
    variables = {
      FOO = "bar"
    }
  }

  assert {
    condition     = github_actions_variable.variables["FOO"].value == "bar"
    error_message = "The variable was not created"
  }
}
