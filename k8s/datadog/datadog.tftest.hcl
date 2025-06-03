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
    node_agent_env = {
      DD_TEST_ENV = "test_value"
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
        { name = "DD_TEST_ENV", value = "test_value" },
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
      nested = {
        foo = "bar"
        baz = "qux"
      }
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
    # Full object with nested values
    condition     = yamldecode(helm_release.datadog_operator.values[0]) == var.extra_values
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

run "cluster_agent_overrides" {
  command = plan

  variables {
    cluster_agent_overrides = {
      tolerations = []
      foo         = "bar"
      whatever = {
        baz = "qux"
      }
    }
  }

  assert {
    condition     = yamldecode(kubectl_manifest.agent.yaml_body_parsed).spec.override.clusterAgent == var.cluster_agent_overrides
    error_message = "Agent manifest was not properly generated"
  }
}

run "features_override" {
  command = plan

  variables {
    logging_enabled = true # To override with features
    features_override = {
      apm = {
        enabled = true
      }
      # Override the default value passed
      logCollection = {
        enabled = false
      }
    }
  }

  assert {
    condition = alltrue([
      yamldecode(kubectl_manifest.agent.yaml_body_parsed).spec.features.logCollection.enabled == false, # Overridden
      yamldecode(kubectl_manifest.agent.yaml_body_parsed).spec.features.apm.enabled == true,
      # Because of overridden object, merge is not a deep merge
      contains(keys(yamldecode(kubectl_manifest.agent.yaml_body_parsed).spec.features.logCollection), "containerCollectAll") == false,
    ])
    error_message = "Agent manifest was not properly generated"
  }
}
