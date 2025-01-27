module "prometheus" {
  source = "../has-crd"
  name   = "servicemonitors.monitoring.coreos.com"
}

resource "kubernetes_namespace_v1" "ns" {
  metadata {
    name = var.namespace
  }
}

module "crd" {
  source = "../crd"
  url    = "https://github.com/cert-manager/cert-manager/releases/download/v${var.chart_version}/cert-manager.crds.yaml"
}

resource "helm_release" "cert_manager" {
  depends_on = [module.crd]
  name       = var.release_name
  chart      = "cert-manager"
  version    = var.chart_version
  namespace  = kubernetes_namespace_v1.ns.metadata[0].name
  repository = "https://charts.jetstack.io"
  atomic     = true
  lint       = true # Useful to detect errors during plan

  set {
    name  = "ingressShim.defaultIssuerName"
    value = var.default_cluster_issuer
  }

  set {
    name  = "ingressShim.defaultIssuerKind"
    value = "ClusterIssuer"
  }

  # Need prometheus to be installed first
  set {
    name  = "prometheus.servicemonitor.enabled"
    value = module.prometheus.has_crd
  }
}

resource "kubernetes_secret_v1" "dns_solver" {
  count = var.do_token != null ? 1 : 0
  metadata {
    name      = local.digitalocean_token_secret
    namespace = helm_release.cert_manager.namespace
  }
  data = {
    (local.digitalocean_token_key) = var.do_token
  }
}

module "cluster_issuer" {
  source = "../has-crd"
  name   = "clusterissuers.cert-manager.io"
}

# On first run this resource won't be installed because the CRD is not present
# https://github.com/hashicorp/terraform-provider-kubernetes/issues/1367#issuecomment-911322756
resource "kubectl_manifest" "default_cluster_issuer" {
  count      = var.default_cluster_issuer != null ? 1 : 0
  depends_on = [helm_release.cert_manager, kubernetes_secret_v1.dns_solver]
  yaml_body = yamlencode({
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"

    metadata = {
      name = var.default_cluster_issuer
    }

    spec = {
      acme = {
        server = local.acme_server
        email  = var.letsencrypt_email
        privateKeySecretRef = {
          name = "${var.default_cluster_issuer}-key"
        }
        solvers = local.solvers
      }
    }
  })

  wait_for {
    condition {
      type   = "Ready"
      status = "True"
    }
  }
}
