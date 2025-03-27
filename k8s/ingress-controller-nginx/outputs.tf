output "load_balancer_ip" {
  description = "The IP of the load balancer on which the ingress controller is exposed"
  # Notice that in digitalocean the load balancer doesn't use ip but name so we need to handle this
  value = var.digitalocean ? data.digitalocean_loadbalancer.cluster_lb[0].ip : "127.0.0.1" # Default to localhost for kind
  # Explicit helm release dependency to ensure the load balancer is created before we try to get the IP
  depends_on = [helm_release.ingress_nginx]
}

output "release_name" {
  description = "The name of the helm release"
  value       = helm_release.ingress_nginx.name
}

# Used in testing
output "namespace" {
  description = "The namespace where the ingress controller is deployed"
  value       = helm_release.ingress_nginx.namespace
}

output "ingress_class_name" {
  description = "The ingress class name created by the ingress controller (DO only)"
  value       = local.ingress_class_name
  depends_on  = [helm_release.ingress_nginx]
}

output "chart_version" {
  description = "Installed chart version of the ingress controller"
  value       = one(helm_release.ingress_nginx.metadata).version
}

output "values" {
  description = "Rendered values through values attributes as object"
  value       = yamldecode(join("\n", helm_release.ingress_nginx.values))
  sensitive   = true
}

output "set" {
  description = "Set values through values attributes as object"
  value       = { for s in nonsensitive(helm_release.ingress_nginx.set) : s.name => s.value if s.name != "globalConfig.signing_key" }
  sensitive   = true
}
