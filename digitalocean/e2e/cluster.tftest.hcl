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

run "domain" {
  module {
    source = "../domain"
  }
  variables {
    name = "e2e.fabn.dev"
    main_records = {
      root     = run.tools.load_balancer_ip
      wildcard = run.tools.load_balancer_ip
    }
  }

  assert {
    condition     = output.domain.name == "e2e.fabn.dev"
    error_message = "The domain was not created"
  }

  assert {
    condition     = output.root_domain_ip == run.tools.load_balancer_ip
    error_message = "The root domain was not created"
  }

  assert {
    condition     = output.wildcard_domain_ip == run.tools.load_balancer_ip
    error_message = "The wildcard domain was not created"
  }
}

# Test DNS record is set correctly
run "host" {
  module {
    source = "../../k8s/http-deployment/host"
  }

  variables {
    host = "e2e.fabn.dev"
  }

  assert {
    condition     = output.ip == run.tools.load_balancer_ip
    error_message = "The DNS record was not created"
  }
}
