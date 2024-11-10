run "create_cluster" {
  module {
    source = "../k8s_cluster"
  }
  variables {
    name   = "e2e-test"
    region = "fra1"
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
    cluster_name           = run.create_cluster.cluster_name
    load_balancer_hostname = "e2e.fabn.dev"
  }

  assert {
    condition     = output.load_balancer_ip != null
    error_message = "The ingress controller was not installed"
  }
}
