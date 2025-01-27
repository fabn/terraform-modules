terraform {
  required_providers {
    kubectl = {
      source = "alekc/kubectl"
    }
  }
}

variable "issuer" {
  description = "The issuer to use for the certificate (if not of kind ClusterIssuer must be in same namespace)"
  type        = string
}

variable "issuer_kind" {
  description = "The kind of the issuer"
  type        = string
  default     = "ClusterIssuer"
}

variable "certificate_name" {
  description = "The name of the certificate"
  type        = string
}

variable "namespace" {
  description = "The namespace to deploy the certificate"
  type        = string
  default     = "default"
}

variable "wait" {
  description = "Whether to wait for the certificate to be ready"
  type        = bool
  default     = true
}

variable "dns_names" {
  description = "List of alternative DNS names for the certificate"
  type        = list(string)
  default     = []
  validation {
    condition     = length(var.dns_names) > 0
    error_message = "At least one DNS name must be provided"
  }
}

resource "kubectl_manifest" "certificate" {
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"

    metadata = {
      name      = var.certificate_name
      namespace = var.namespace
    }

    spec = {
      secretName = "${var.certificate_name}-tls"
      issuerRef = {
        name = var.issuer
        kind = var.issuer_kind
      }
      dnsNames = var.dns_names
    }
  })

  # Conditional wait for certificate to be ready
  dynamic "wait_for" {
    for_each = var.wait ? [1] : []
    content {
      condition {
        type   = "Ready"
        status = "True"
      }
    }
  }
}

data "kubernetes_secret_v1" "tls" {
  metadata {
    name      = "${var.certificate_name}-tls"
    namespace = var.namespace
  }
  depends_on = [kubectl_manifest.certificate]
}

output "certificate" {
  description = "The certificate object as certificate.cert-manager.io"
  value       = kubectl_manifest.certificate
  sensitive   = true
}

output "spec" {
  description = "The spec of the certificate extracted from the manifest"
  value       = yamldecode(kubectl_manifest.certificate.yaml_body_parsed).spec
  sensitive   = true
}

output "secret" {
  description = "The secret containing the certificate"
  value       = data.kubernetes_secret_v1.tls
  sensitive   = true
}
