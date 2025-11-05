terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

locals {
  labels = {
    "terraform/app"       = var.name
    "terraform/namespace" = var.namespace
    "terraform/module"    = basename(path.cwd) # Add the folder that triggered the deployment as module
  }

  ingress_annotations = merge(var.ingress_annotations, var.acme_tls ? {
    "kubernetes.io/tls-acme" = "true"
  } : {})

  # Replicates https://github.com/bitnami/charts/blob/main/bitnami/common/templates/_affinities.tpl
  anti_affinity = "hard"

  namespace = var.create_namespace ? kubernetes_namespace_v1.ns.0.metadata.0.name : var.namespace
}

module "log_annotations" {
  source = "../log_tags"
  # Log rules must point to container name unless check id is specified
  container_name = coalesce(var.dd_check_id, lookup(var.dd_log_tags, "container_name"), var.name)
  log_source     = lookup(var.dd_log_tags, "source")
  service        = var.dd_tags.service != null ? var.dd_tags.service : lookup(var.dd_log_tags, "service")
  exclude        = lookup(var.dd_log_tags, "exclude", [])

  # Pass the checks to the module
  checks   = var.dd_checks
  check_id = var.dd_check_id
}
module "labels" {
  source  = "../service_tags"
  dd_tags = var.dd_tags
}

resource "kubernetes_namespace_v1" "ns" {
  count = var.create_namespace ? 1 : 0
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_deployment_v1" "deployment" {
  metadata {
    namespace = local.namespace
    name      = var.name
    labels    = merge(local.labels, module.labels.tags)
  }
  spec {
    replicas = var.replicas
    selector {
      match_labels = local.labels
    }
    template {
      metadata {
        labels      = merge(local.labels, module.labels.tags)
        annotations = merge(module.labels.annotations, module.log_annotations.annotations, var.pod_annotations)
      }
      spec {
        container {
          name        = var.name
          image       = var.image
          command     = var.command
          args        = var.args
          working_dir = var.working_dir

          dynamic "port" {
            for_each = var.ports
            content {
              container_port = port.value
              name           = port.key
              protocol       = "TCP"
            }
          }

          # Config map references
          dynamic "env_from" {
            for_each = var.config_maps
            content {
              config_map_ref {
                name = env_from.value
              }
            }
          }

          # Secret references
          dynamic "env_from" {
            for_each = var.secrets
            content {
              secret_ref {
                name = env_from.value
              }
            }
          }

          dynamic "env_from" {
            for_each = var.env_from
            content {
              # name = env_from.value
              prefix = env_from.value.prefix
              dynamic "config_map_ref" {
                for_each = env_from.value.config_map[*]
                content {
                  name = config_map_ref.value
                }
              }
              dynamic "secret_ref" {
                for_each = env_from.value.secret[*]
                content {
                  name = secret_ref.value
                }
              }
            }
          }

          # Plain environment variables
          dynamic "env" {
            for_each = var.envs
            content {
              name  = env.key
              value = env.value
            }
          }

          # Env references from existing secrets
          dynamic "env" {
            for_each = var.env_references

            content {
              name = env.value.name
              value_from {
                secret_key_ref {
                  name     = env.value.secret_key_ref.name
                  key      = env.value.secret_key_ref.key
                  optional = env.value.secret_key_ref.optional
                }
              }
            }
          }

          # Health checks
          dynamic "startup_probe" {
            for_each = length(compact([var.startup_probe_path, var.http_probe_path])) > 0 ? [1] : []
            content {
              http_get {
                path = coalesce(var.startup_probe_path, var.http_probe_path)
                port = "http"
              }
            }
          }
          dynamic "liveness_probe" {
            for_each = var.http_probe_path != null ? [1] : []
            content {
              http_get {
                path = var.http_probe_path
                port = "http"
              }
            }
          }
          dynamic "readiness_probe" {
            for_each = var.http_probe_path != null ? [1] : []
            content {
              http_get {
                path = var.http_probe_path
                port = "http"
              }
            }
          }

          resources {
            limits = {
              # Never set any CPU limit
              memory = coalesce(var.memory_limits, var.memory_requests, "1Gi")
            }
            requests = {
              cpu    = var.cpu_requests
              memory = var.memory_requests
            }
          }

          # Mount passed volumes
          dynamic "volume_mount" {
            for_each = var.volumes
            content {
              mount_path = volume_mount.value.mount_path
              name       = volume_mount.value.name
              sub_path   = volume_mount.value.sub_path
              read_only  = try(volume_mount.value.read_only, false)
            }
          }

          # Mount empty dirs
          dynamic "volume_mount" {
            for_each = var.empty_dirs
            content {
              name       = "${basename(volume_mount.value)}-empty-dir"
              mount_path = volume_mount.value
            }
          }
        }

        dynamic "image_pull_secrets" {
          for_each = var.image_pull_secrets != null ? [1] : []
          content {
            name = var.image_pull_secrets
          }
        }

        # Pod anti-affinity by hostname, is a sane default can be soft or hard
        dynamic "affinity" {
          for_each = var.anti_affinity != null ? [1] : []
          content {
            pod_anti_affinity {
              # This is the hard anti-affinity rule
              dynamic "required_during_scheduling_ignored_during_execution" {
                for_each = var.anti_affinity == "hard" ? [1] : []
                content {
                  topology_key = "kubernetes.io/hostname"
                  label_selector {
                    match_labels = local.labels
                  }
                }
              }
              # This is the soft anti-affinity rule
              dynamic "preferred_during_scheduling_ignored_during_execution" {
                for_each = var.anti_affinity == "soft" ? [1] : []
                content {
                  weight = 1
                  pod_affinity_term {
                    topology_key = "kubernetes.io/hostname"
                    label_selector {
                      match_labels = local.labels
                    }
                  }
                }
              }
            }
          }
        }
        # Pass a custom service account if given
        service_account_name = var.service_account_name

        # Declare volumes according to the passed list
        dynamic "volume" {
          for_each = var.volumes
          content {
            name = volume.value.name

            dynamic "secret" {
              for_each = volume.value.secret != null ? [volume.value.secret] : []
              content {
                default_mode = volume.value.mode
                secret_name  = secret.value
              }
            }
            dynamic "config_map" {
              for_each = volume.value.config_map != null ? [volume.value.config_map] : []
              content {
                name         = volume.value.config_map
                default_mode = volume.value.mode
              }
            }
          }
        }
        # Declare volumes according to the passed list
        dynamic "volume" {
          for_each = var.empty_dirs
          content {
            name = "${basename(volume.value)}-empty-dir"
            empty_dir {}
          }
        }

        dynamic "init_container" {
          for_each = var.init_command != null ? [var.init_command] : []
          content {
            name        = "init-command"
            image       = coalesce(init_container.value.image, var.image)
            working_dir = var.working_dir
            command     = init_container.value.command
            args        = init_container.value.args
            # Plain environment variables
            dynamic "env" {
              for_each = var.envs
              content {
                name  = env.key
                value = env.value
              }
            }
            # Mount passed volumes
            dynamic "volume_mount" {
              for_each = var.volumes
              content {
                mount_path = volume_mount.value.mount_path
                name       = volume_mount.value.name
                sub_path   = volume_mount.value.sub_path
                read_only  = try(volume_mount.value.read_only, false)
              }
            }
            # Mount empty dirs
            dynamic "volume_mount" {
              for_each = var.empty_dirs
              content {
                name       = "${basename(volume_mount.value)}-empty-dir"
                mount_path = volume_mount.value
              }
            }
          }
        }
      }
    }
  }
}
resource "kubernetes_service_v1" "service" {
  count = var.service_type != null && length(var.ports) > 0 ? 1 : 0
  metadata {
    namespace = local.namespace
    name      = var.name
    labels    = kubernetes_deployment_v1.deployment.spec[0].selector[0].match_labels
  }
  spec {
    type     = var.service_type
    selector = local.labels
    dynamic "port" {
      for_each = var.ports
      content {
        name        = port.key
        port        = port.value
        target_port = port.value
      }
    }
  }
}

resource "kubernetes_ingress_v1" "ingress" {
  wait_for_load_balancer = true
  count                  = min(length(var.ingress_hostnames), 1)
  metadata {
    namespace   = local.namespace
    name        = var.name
    annotations = local.ingress_annotations
  }
  spec {

    dynamic "rule" {
      for_each = var.ingress_hostnames
      content {
        host = rule.value
        http {
          path {
            path = "/"
            backend {
              service {
                name = one(kubernetes_service_v1.service[0].metadata).name
                port {
                  name = one(kubernetes_service_v1.service[0].spec).port.0.name
                }
              }
            }
          }
        }
      }
    }

    dynamic "tls" {
      for_each = var.ingress_hostnames != [] ? [1] : []
      content {
        hosts       = var.ingress_hostnames
        secret_name = "${var.name}-tls-ingress"
      }
    }
  }
}
