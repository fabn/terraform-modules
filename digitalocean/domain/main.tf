terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
}

# Create the domain object
resource "digitalocean_domain" "domain" {
  name = var.name
}

# If requested also create the A record and the * record
resource "digitalocean_record" "wildcard" {
  domain = digitalocean_domain.domain.name
  type   = "A"
  name   = "*"
  ttl    = 1800
  value  = var.main_records.wildcard
}

resource "digitalocean_record" "root" {
  domain = digitalocean_domain.domain.name
  type   = "A"
  name   = "@"
  ttl    = 1800
  value  = var.main_records.root
}

resource "digitalocean_record" "records" {
  for_each = { for record in var.records : record.name => record }
  name     = each.key
  domain   = digitalocean_domain.domain.name
  type     = each.value.type
  value    = each.value.value
  ttl      = each.value.ttl
}
