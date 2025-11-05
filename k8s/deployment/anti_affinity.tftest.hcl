variables {
  image            = "ealen/echo-server:latest"
  namespace        = "deployment-test"
  create_namespace = true
}

run "default_pod_anti_affinity" {
  variables {
    name = "aa-default" # need to use a different name to avoid label conflict
  }

  assert {
    condition     = var.anti_affinity == "soft"
    error_message = "Default is soft"
  }

  assert {
    condition     = kubernetes_deployment_v1.deployment.spec.0.template.0.spec.0.affinity.0.pod_anti_affinity.0.preferred_during_scheduling_ignored_during_execution.0.weight == 1
    error_message = "Sets the weight to 1"
  }

  assert {
    condition     = kubernetes_deployment_v1.deployment.spec.0.template.0.spec.0.affinity.0.pod_anti_affinity.0.preferred_during_scheduling_ignored_during_execution.0.pod_affinity_term.0.topology_key == "kubernetes.io/hostname"
    error_message = "Skips the anti_affinity in template"
  }
}

run "pod_anti_affinity_null" {
  variables {
    name          = "aa-null" # need to use a different name to avoid label conflict
    anti_affinity = null
  }

  assert {
    condition     = length(kubernetes_deployment_v1.deployment.spec.0.template.0.spec.0.affinity) == 0
    error_message = "Skips the anti_affinity in template"
  }
}

run "pod_anti_affinity_hard" {
  variables {
    name          = "aa-hard" # need to use a different name to avoid label conflict
    anti_affinity = "hard"
  }

  assert {
    condition     = kubernetes_deployment_v1.deployment.spec.0.template.0.spec.0.affinity.0.pod_anti_affinity.0.required_during_scheduling_ignored_during_execution.0.topology_key == "kubernetes.io/hostname"
    error_message = "Uses the proper topology key"
  }
}
