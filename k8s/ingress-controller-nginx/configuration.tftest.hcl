run "install_helm_release" {
  command = plan

  assert {
    condition     = output.release_name == "ingress-nginx"
    error_message = "Wrong release name"
  }

  assert {
    condition = alltrue([
      output.values.controller.autoscaling.minReplicas == 1
    ])
    error_message = "Output values properly computed"
  }
}
