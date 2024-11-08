
output "host" {
  value = kubernetes_ingress_v1.ingress.spec.0.rule.0.host
}

output "url" {
  value = "${local.output_scheme}://${kubernetes_ingress_v1.ingress.spec.0.rule.0.host}"
}
