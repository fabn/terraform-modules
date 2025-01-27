provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-kind"
}

provider "kubectl" {
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
  chart_version = "1.16.3"
}

run "helm_release" {
  assert {
    condition     = output.release_name == "cert-manager"
    error_message = "Wrong release name"
  }

  assert {
    condition     = output.namespace == "cert-manager"
    error_message = "Wrong namespace"
  }

  assert {
    condition     = output.default_cluster_issuer == "letsencrypt-cluster-issuer"
    error_message = "Wrong Issuer name"
  }
}

run "create_wildcard_certificate" {
  variables {
    issuer           = run.helm_release.default_cluster_issuer
    certificate_name = "star-dot-dev"
    dns_names        = ["*.test.fabn.dev"]
  }

  module {
    source = "./certificate"
  }

  assert {
    condition     = output.certificate.name == "star-dot-dev"
    error_message = "Wrong certificate name"
  }

  assert {
    condition     = output.spec.issuerRef.name == run.helm_release.default_cluster_issuer
    error_message = "Wrong issuer used"
  }

  assert {
    condition     = contains(output.spec.dnsNames, "*.test.fabn.dev")
    error_message = "Wrong DNS name given"
  }

  assert {
    condition     = one(output.secret.metadata).name == "star-dot-dev-tls"
    error_message = "Wrong DNS name"
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
