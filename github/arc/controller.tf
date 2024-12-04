resource "kubernetes_namespace_v1" "arc_system" {
  metadata {
    name = var.controller_namespace
  }
}

resource "helm_release" "arc" {
  name      = "arc"
  chart     = "oci://ghcr.io/actions/actions-runner-controller-charts/gha-runner-scale-set-controller"
  version   = var.controller_version
  namespace = one(kubernetes_namespace_v1.arc_system.metadata).name
  values = [
    var.controller_override_values
  ]
}

output "controller_version" {
  value = helm_release.arc.version
}
