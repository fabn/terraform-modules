module "default_ingress_class" {
  source = "../default-ingress-class"
}

locals {
  production_server = "https://acme-v02.api.letsencrypt.org/directory"
  staging_server    = "https://acme-staging-v02.api.letsencrypt.org/directory"
  acme_server       = var.production ? local.production_server : local.staging_server
  # Local variables for DO token
  digitalocean_token_secret = "digitalocean-dns"
  digitalocean_token_key    = "access-token"

  # Solvers conditions
  has_http_solver = module.default_ingress_class.exist
  has_dns_solver  = var.do_token != null

  # Declare challenge solvers
  http_solver = {
    http01 = {
      ingress = {
        class = module.default_ingress_class.name
      }
    }
  }

  dns_solver = {
    dns01 = {
      digitalocean = {
        tokenSecretRef = {
          name = local.digitalocean_token_secret
          key  = local.digitalocean_token_key
        }
      }
    }
  }

  # Create the final list of solvers see
  # https://github.com/hashicorp/terraform/issues/33259#issuecomment-1914706111
  solvers = flatten(concat(
    (local.has_http_solver ? [local.http_solver] : []),
    (local.has_dns_solver ? [local.dns_solver] : [])
  ))
}

