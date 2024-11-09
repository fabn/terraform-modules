run "create_cluster" {
	module {
	  source = "../k8s_cluster"
	}
  variables {
    cluster_name = "e2e-test"
		region.      = "fra1"
  }
  assert {
    condition     = output.cluster_name == "e2e-test"
    error_message = "The cluster was not created"
  }
}

run "tools" {
	module {
	  source = "../k8s_cluster_tools"
	}
  variables {
    cluster_name           = run.create_cluster.output.cluster_name
    load_balancer_hostname = "e2e.fabn.dev"
  }
  # assert {
  #   condition     = module.cluster_tools.ingress_controller.enabled == true
  #   error_message = "The ingress controller was not enabled"
  # }
}
