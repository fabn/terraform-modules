terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

# Used for testing purposes to generate unique hostnames
resource "random_uuid" "uuid" {
}

output "uuid" {
  value = random_uuid.uuid.id
}
