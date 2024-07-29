output "domain" {
  value = digitalocean_domain.domain
}

output "root_domain_ip" {
  value = digitalocean_record.root.value
}

output "wildcard_domain_ip" {
  value = digitalocean_record.wildcard.value
}

output "records" {
  value = digitalocean_record.records
}
