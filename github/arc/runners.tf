resource "random_id" "name" {
  for_each    = var.scale_set_name_prefix != null ? var.runners : {}
  byte_length = 4 # will be used for the scale set name produce 8 hex chars
}

resource "kubernetes_namespace_v1" "runners" {
  metadata {
    name = var.runners_namespace
  }
}

resource "helm_release" "runners" {
  for_each   = var.runners
  depends_on = [helm_release.arc] # Wait for controller to be up and running
  name       = var.scale_set_name_prefix != null ? "${var.scale_set_name_prefix}-${random_id.name[each.key].hex}" : "scale-set-${each.key}"
  chart      = "oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set"
  version    = var.runners_version
  namespace  = one(kubernetes_namespace_v1.runners.metadata).name
  values = compact([
    # Auth credentials, will be marked as sensitive
    templatefile("${path.module}/auth.yml", {
      github_token : var.github_token,
      github_config_secret : var.github_config_secret,
    }),
    templatefile("${path.module}/resources.yml", {
      requests : each.value.requests
      limits : each.value.limits
    }),
    each.value.values != null ? each.value.values : null
  ])

  set {
    name  = "runnerScaleSetName"
    value = each.key
  }

  dynamic "set" {
    for_each = each.value.runner_group != null ? [1] : []
    content {
      name  = "runnerGroup"
      value = each.value.runner_group
    }
  }

  # Mandatory to link the scale set to a given repo/organization
  set {
    name  = "githubConfigUrl"
    value = var.github_config_url
  }

  set {
    name  = "minRunners"
    value = coalesce(each.value.min_runners, var.min_runners, 0)
  }

  set {
    name  = "maxRunners"
    value = coalesce(each.value.max_runners, var.max_runners, 10)
  }

  lifecycle {
    precondition {
      condition     = var.github_token != null || var.github_config_secret != null
      error_message = "Either github_token or github_config_secret must be set"
    }
  }
}

output "runners_version" {
  value = length(var.runners) > 0 ? helm_release.runners[keys(var.runners)[0]].version : null
}

output "scale_set_names" {
  depends_on  = [helm_release.runners]
  description = "The name of the deployed scale set to use in workflow files"
  value       = [for k, v in helm_release.runners : helm_release.runners[k].name]
}

output "config" {
  value = nonsensitive(var.github_config_secret)
}

output "yaml" {
  value = templatefile("${path.module}/auth.yml", {
    github_token : nonsensitive(var.github_token),
    github_config_secret : nonsensitive(var.github_config_secret),
  })
}
