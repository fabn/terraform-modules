provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-kind"
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
    config_context = "kind-kind"
  }
}

variables {
  hostname = "rancher.fabn.dev"
  replicas = 1
}

# Passing letsencrypt configuration
run "letsencrypt" {
  command = plan
  variables {
    letsencrypt = {
      enabled     = true
      email       = "user@example.com"
      environment = "staging"
    }
  }

  assert {
    condition     = output.set["tls"] == "ingress"
    error_message = "Wrong tls configuration"
  }

  assert {
    condition = alltrue([
      output.values.ingress.tls.source == "letsEncrypt",
      output.values.letsEncrypt.email == "user@example.com",
      output.values.letsEncrypt.environment == "staging",
    ])
    error_message = "Wrong letsencrypt configuration"
  }
}

run "letsencrypt_production" {
  command = plan
  variables {
    letsencrypt = {
      enabled = true
      email   = "user@example.com"
    }
  }

  assert {
    condition     = output.set["tls"] == "ingress"
    error_message = "Wrong tls configuration"
  }

  assert {
    condition     = output.values.letsEncrypt.environment == "production"
    error_message = "Wrong letsencrypt configuration"
  }
}

run "extra_values" {
  command = plan
  variables {
    extra_values = {
      resources = {
        limits = {
          cpu    = "1"
          memory = "1Gi"
        }
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }
      }
    }
  }

  assert {
    condition = alltrue([
      output.values.resources.requests.cpu == "100m",
      output.values.resources.requests.memory == "128Mi",
      output.values.resources.limits.cpu == "1",
      output.values.resources.limits.memory == "1Gi",
    ])
    error_message = "Wrong extra values"
  }
}
