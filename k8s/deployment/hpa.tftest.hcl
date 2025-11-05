variables {
  create_namespace = true
  # These are the minimal requirements to have a deployment using this module
  name       = "echo"
  namespace  = "hpa-test"
  image      = "ealen/echo-server:latest"
  create_hpa = true
  hpa_params = {
    max_replicas = 10
    pod_metrics = {
      custom_metric_1 = 1
      custom_metric_2 = 42
    }
  }
}

run "with_hpa" {
  command = plan
  assert {
    condition     = kubernetes_horizontal_pod_autoscaler_v2.hpa[0].metadata[0].name == "echo-hpa"
    error_message = "Uses the proper name"
  }

  assert {
    condition = alltrue([
      kubernetes_horizontal_pod_autoscaler_v2.hpa[0].spec[0].scale_target_ref[0].name == kubernetes_deployment_v1.deployment.metadata[0].name,
      kubernetes_horizontal_pod_autoscaler_v2.hpa[0].spec[0].scale_target_ref[0].api_version == "apps/v1",
      kubernetes_horizontal_pod_autoscaler_v2.hpa[0].spec[0].scale_target_ref[0].kind == "Deployment",
    ])
    error_message = "It points to the deployment"
  }

  assert {
    condition = alltrue([
      kubernetes_horizontal_pod_autoscaler_v2.hpa[0].spec[0].min_replicas == 1,
      kubernetes_horizontal_pod_autoscaler_v2.hpa[0].spec[0].max_replicas == 10,
    ])
    error_message = "It configures the replicas"
  }

  assert {
    condition = alltrue([
      kubernetes_horizontal_pod_autoscaler_v2.hpa[0].spec[0].metric[0].type == "Pods",
      kubernetes_horizontal_pod_autoscaler_v2.hpa[0].spec[0].metric[0].pods[0].metric[0].name == "custom_metric_1",
      kubernetes_horizontal_pod_autoscaler_v2.hpa[0].spec[0].metric[0].pods[0].target[0].type == "Value",
      kubernetes_horizontal_pod_autoscaler_v2.hpa[0].spec[0].metric[0].pods[0].target[0].average_value == "1",
      kubernetes_horizontal_pod_autoscaler_v2.hpa[0].spec[0].metric[1].pods[0].metric[0].name == "custom_metric_2",
      kubernetes_horizontal_pod_autoscaler_v2.hpa[0].spec[0].metric[1].pods[0].target[0].type == "Value",
      kubernetes_horizontal_pod_autoscaler_v2.hpa[0].spec[0].metric[1].pods[0].target[0].average_value == "42",
      length(kubernetes_horizontal_pod_autoscaler_v2.hpa[0].spec[0].metric) == 2, # Configure both metrics
    ])
    error_message = "It configures the metrics"
  }
}
