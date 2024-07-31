mock_provider "github" {}

run "create_team" {
  variables {
    name        = "Devs"
    description = "Main developers"
    members     = ["some-member"]
    maintainers = ["some-maintainer"]
    repos = {
      "terraform-modules" = "push", # AKA write
      "some-repo"         = "pull", # aka readonly
    }
  }

  assert {
    condition     = output.team.name == "Devs"
    error_message = "The team was not created"
  }

  assert {
    condition = lookup(tomap({
      for m in github_team_members.users.0.members : m["username"] => m["role"]
    }), "some-member") == "member"
    error_message = "The team member were not added"
  }

  assert {
    condition = lookup(tomap({
      for m in github_team_members.users.0.members : m["username"] => m["role"]
    }), "some-maintainer") == "maintainer"
    error_message = "The team maintainer were not added"
  }

  assert {
    condition     = github_team_repository.permissions["terraform-modules"].permission == "push" && github_team_repository.permissions["some-repo"].permission == "pull"
    error_message = "Proper permissions was not created"
  }
}

run "create_team_with_no_members" {
  variables {
    name = "Empty Team"
  }

  assert {
    condition     = length(github_team_members.users) == 0
    error_message = "The team was not empty"
  }
}
