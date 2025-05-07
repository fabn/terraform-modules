variables {
  cluster_name = "demo"
  dd_api_key   = "1234567890"
  dd_site      = "datadoghq.com"
  global_tags = {
    env = "test"
  }
}

run "default_install" {
  command = plan

  assert {
    condition     = kubernetes_namespace_v1.ns.metadata[0].name == var.namespace
    error_message = "Namespace was not created"
  }

  assert {
    condition = alltrue([
      kubernetes_secret_v1.api_key.data["api_key"] == var.dd_api_key,
      kubernetes_secret_v1.api_key.metadata[0].namespace == var.namespace
    ])
    error_message = "The secret was not created"
  }
}

run "logs_and_discovery" {
  command = plan
  variables {
    logging_enabled = true
    discovered_namespaces = {
      included_namespaces = ["default", "kube-system"]
    }
  }

  assert {
    condition = alltrue([
      yamldecode(kubectl_manifest.agent.yaml_body_parsed).spec.features.logCollection.enabled == var.logging_enabled,
      yamldecode(kubectl_manifest.agent.yaml_body_parsed).spec.features.logCollection.containerCollectAll == var.collect_all_logging,
    ])
    error_message = "Agent manifest was not properly generated"
  }

  assert {
    condition = alltrue([
      local.included_namespaces == ["kube_namespace:default", "kube_namespace:kube-system"],
      local.excluded_namespaces == [],
      local.agent_env == [
        { name = "DD_CONTAINER_EXCLUDE", value = "" },
        { name = "DD_CONTAINER_INCLUDE", value = "kube_namespace:default kube_namespace:kube-system" },
      ],
    ])
    error_message = "Exclude list is properly generated"
  }
}

run "with_extra_values" {
  command = plan

  variables {
    # Extra values can only be used with a map of same elements
    extra_values = {
      foo = "bar"
      baz = "qux"
    }
    extra_yaml = <<-YML
      super:
        foo: bar
        baz: qux
      resources:
        limits:
          memory: 1Gi
        requests:
          cpu: 100m
          memory: 1Gi
    YML
  }

  assert {
    condition = alltrue([
      yamldecode(helm_release.datadog_operator.values[0]).foo == var.extra_values.foo,
      yamldecode(helm_release.datadog_operator.values[0]).baz == var.extra_values.baz,
    ])
    error_message = "Extra values were not properly passed to the chart"
  }
  assert {
    condition     = helm_release.datadog_operator.values[1] == var.extra_yaml
    error_message = "Extra values yaml were not properly passed to the chart"
  }
}

run "node_overrides" {
  command = plan

  variables {
    datadog_agent_overrides = {
      tolerations = []
      foo         = "bar"
      whatever = {
        baz = "qux"
      }
    }
  }

  assert {
    condition = alltrue([
      yamldecode(kubectl_manifest.agent.yaml_body_parsed).spec.override.nodeAgent.tolerations == [],
      yamldecode(kubectl_manifest.agent.yaml_body_parsed).spec.override.nodeAgent.whatever.baz == "qux",
    ])
    error_message = "Agent manifest was not properly generated"
  }
}
