terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    http = {
      source = "hashicorp/http"
    }
  }
}

data "http" "crds" {
  url = var.url
  lifecycle {
    postcondition {
      condition     = self.status_code / 100 == 2 # Any 2xx status code
      error_message = "The request failed with status code ${self.status_code}"
    }
  }
}

locals {
  # CRD YAML content
  crds_yaml = data.http.crds.response_body

  # Split by YAML documents ("---" is too generic, we need to split by "\n---\n")
  yaml_documents = split("\n---\n", local.crds_yaml)

  # Decode YAML documents
  decoded_documents = [
    for doc in local.yaml_documents : yamldecode(trimspace(doc))
    if trimspace(doc) != ""
  ]

  # CRDs as name => CRD (as object)
  crds = { for idx, doc in local.decoded_documents : doc.metadata.name => doc }
}

# Install them as kubernetes manifests
resource "kubernetes_manifest" "crd" {
  for_each = local.crds
  manifest = each.value
}
