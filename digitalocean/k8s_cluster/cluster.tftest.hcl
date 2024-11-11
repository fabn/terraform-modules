run "with_null_node_size" {
  command = plan
  variables {
    name       = "e2e-test"
    region     = "fra1"
    node_count = 1
    node_size  = null # In this way it will use the cheapest available
  }

  assert {
    condition     = output.cluster_name == "e2e-test"
    error_message = "The cluster was not created"
  }

  assert {
    condition     = one(output.cluster.node_pool).size == "s-1vcpu-1gb"
    error_message = "The cheapest node size was not set correctly"
  }

  assert {
    condition     = one(output.cluster.node_pool).node_count == 1
    error_message = "The node count was not set correctly"
  }

  assert {
    condition     = output.kubernetes_version == data.digitalocean_kubernetes_versions.available.latest_version && output.cluster.version == output.kubernetes_version
    error_message = "The used version was not set correctly"
  }
}
