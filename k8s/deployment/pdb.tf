resource "kubernetes_pod_disruption_budget_v1" "pdb" {
  count = var.create_pdb ? 1 : 0
  metadata {
    name      = "${var.name}-pdb"
    namespace = kubernetes_deployment_v1.deployment.metadata[0].namespace
    labels    = kubernetes_deployment_v1.deployment.spec[0].selector[0].match_labels
  }
  spec {
    max_unavailable = 1
    selector {
      match_labels = kubernetes_deployment_v1.deployment.spec[0].selector[0].match_labels
    }
  }
}
