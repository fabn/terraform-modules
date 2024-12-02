resource "kubernetes_namespace_v1" "arc_system" {
  count = var.controller_enabled ? 1 : 0
  metadata {
    name = var.controller_namespace
  }
}

resource "helm_release" "arc" {
  count     = var.controller_enabled ? 1 : 0
  name      = "arc"
  chart     = "oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller"
  version   = var.controller_version
  namespace = one(one(kubernetes_namespace_v1.arc_system).metadata).name
  values = [
    var.controller_override_values
  ]
}

output "controller_version" {
  value = var.controller_enabled ? helm_release.arc.0.version : null
}
