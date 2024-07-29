provider "digitalocean" {
  token = var.do_token
}

run "create_domain" {
  variables {
    name = "terraform.dev"
    main_records = {
      wildcard = "127.0.0.1"
      root     = "127.0.0.2"
    }
    records = [
      {
        name  = "test"
        type  = "CNAME"
        value = "example.com."
      },
      {
        name  = "another"
        type  = "A"
        value = "127.0.0.3"
      }
    ]
  }

  assert {
    condition     = output.domain.name == "terraform.dev"
    error_message = "The domain was not created"
  }

  assert {
    condition     = output.wildcard_domain_ip == "127.0.0.1"
    error_message = "The root domain IP was not created"
  }

  assert {
    condition     = output.root_domain_ip == "127.0.0.2"
    error_message = "The root domain IP was not created"
  }
}
