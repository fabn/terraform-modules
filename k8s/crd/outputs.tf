output "crds" {
  description = "The CRDs fetched from url as name => CRD (as object)"
  value       = local.crds
}

output "full_yaml" {
  description = "The full CRD YAML content fetched from url"
  value       = local.crds_yaml
}
