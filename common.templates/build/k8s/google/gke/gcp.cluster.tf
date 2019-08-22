#if( ${containerObject} )
#set( $appName = "Container-${containerObject.getName()}" )
#else
#set( $appName = $aib.getApplicationNameFormatted() )
#end
#####################################################################
# GKE Cluster
#####################################################################
resource "google_container_cluster" "${appName}-cluster" {
  name               = "${appName}-cluster"
  zone               = "${esc.dollar}{var.region}"
  initial_node_count = 3

  addons_config {
    network_policy_config {
      disabled = true
    }
  }

  master_auth {
    username = "${esc.dollar}{var.username}"
    password = "${esc.dollar}{var.password}"
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/compute",
    ]
  }
}

#####################################################################
# Output for K8S
#####################################################################
output "client_certificate" {
  value     = "${esc.dollar}{google_container_cluster.${appName}-cluster.master_auth.0.client_certificate}"
  sensitive = true
}

output "client_key" {
  value     = "${esc.dollar}{google_container_cluster.${appName}-cluster.master_auth.0.client_key}"
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = "${esc.dollar}{google_container_cluster.${appName}-cluster.master_auth.0.cluster_ca_certificate}"
  sensitive = true
}

output "host" {
  value     = "${esc.dollar}{google_container_cluster.${appName}-cluster.endpoint}"
  sensitive = true
}