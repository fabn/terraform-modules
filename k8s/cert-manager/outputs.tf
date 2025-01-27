output "release_name" {
  value = helm_release.cert_manager.name
}

output "namespace" {
  value = helm_release.cert_manager.namespace
}

output "default_cluster_issuer" {
  value = one(kubectl_manifest.default_cluster_issuer[*].name)
}

output "chart_version" {
  description = "Installed chart version of the cert manager helm chart"
  value       = one(helm_release.cert_manager.metadata).version
}

output "set" {
  description = "Set values through values attributes as object"
  value       = { for s in nonsensitive(helm_release.cert_manager.set) : s.name => s.value }
  sensitive   = true
}
