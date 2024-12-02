locals {
  scale_set_name = var.scale_set_name_prefix != null ? "${var.scale_set_name_prefix}-${random_id.name.0.hex}" : coalesce(var.runners_scale_set_name, var.runners_release_name)
}

resource "random_id" "name" {
  count       = var.scale_set_name_prefix != null ? 1 : 0
  byte_length = 4 # will be used for the scale set name produce 8 hex chars
}

resource "kubernetes_namespace_v1" "runners" {
  metadata {
    name = var.runners_namespace
  }
}

resource "helm_release" "runners" {
  depends_on = [helm_release.arc] # Wait for controller to be up and running
  name       = var.runners_release_name
  chart      = "oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set"
  version    = var.runners_version
  namespace  = one(kubernetes_namespace_v1.runners.metadata).name
  values = [
    # Auth credentials, will be marked as sensitive
    templatefile("${path.module}/auth.yml", {
      github_token : var.github_token,
      github_config_secret : var.github_config_secret,
    }),
  ]

  set {
    name  = "runnerScaleSetName"
    value = local.scale_set_name
  }

  dynamic "set" {
    for_each = var.runner_group[*]
    content {
      name  = "runnerGroup"
      value = var.runner_group
    }
  }

  # Mandatory to link the scale set to a given repo/organization
  set {
    name  = "githubConfigUrl"
    value = var.github_config_url
  }

  set {
    name  = "minRunners"
    value = var.min_runners
  }

  set {
    name  = "maxRunners"
    value = var.max_runners
  }

  lifecycle {
    precondition {
      condition     = var.github_token != null || var.github_config_secret != null
      error_message = "Either github_token or github_config_secret must be set"
    }
  }
}

output "runners_version" {
  value = helm_release.runners.version
}

output "scale_set_name" {
  depends_on  = [helm_release.runners]
  description = "The name of the scale set to use in workflow files"
  value       = local.scale_set_name
}
