mock_provider "rancher2" {
  mock_resource "rancher2_bootstrap" {
    defaults = {
      token    = "access_key:secret_key"
      token_id = "access_key"
    }
  }
}

run "default" {
  assert {
    condition     = (output.admin_password != null && output.bootstrap_password != null)
    error_message = "Didn't generate credentials"
  }
}

run "token_generation" {
  assert {
    condition = alltrue([
      output.rancher_token.api_token == "access_key:secret_key",
      output.rancher_token.access_key == "access_key",
      output.rancher_token.secret_key == "secret_key"
    ])
    error_message = "Didn't generate token"
  }
}

run "with_given_passwords" {
  variables {
    admin_password     = "superSecret1234"
    bootstrap_password = "superBootstrap1234"
  }

  assert {
    condition     = output.admin_password == var.admin_password && output.bootstrap_password == var.bootstrap_password
    error_message = "Didn't generate credentials"
  }
}
