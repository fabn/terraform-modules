variable "host" {
  description = "The host to resolve"
  type        = string
}

data "dns_a_record_set" "host" {
  host = var.host
}

output "ip" {
  value = join(",", data.dns_a_record_set.host.addrs)
}
