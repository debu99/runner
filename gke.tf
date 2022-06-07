
# VPC
resource "google_compute_network" "vpc" {
  name                    = "${var.name_prefix}-vpc"
  auto_create_subnetworks = "false"
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.name_prefix}-subnet"
  region        = lower(var.gcp_region)
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/17"

  secondary_ip_range {
    range_name    = "${var.name_prefix}-gke-pods-${random_string.suffix.result}"
    ip_cidr_range = "192.168.0.0/18"
  }

  secondary_ip_range {
    range_name    = "${var.name_prefix}-gke-services-${random_string.suffix.result}"
    ip_cidr_range = "192.168.64.0/18"
  }
}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  version                    = "21.1.0"
  project_id                 = var.gcp_project
  name                       = "${var.name_prefix}-gke"
  regional                   = false
  region                     = var.gcp_region
  zones                      = [var.gcp_zone]
  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false

  network           = google_compute_network.vpc.name
  subnetwork        = google_compute_subnetwork.subnet.name
  ip_range_pods     = google_compute_subnetwork.subnet.secondary_ip_range[0].range_name
  ip_range_services = google_compute_subnetwork.subnet.secondary_ip_range[1].range_name

  node_pools = [
    {
      name         = "node-pool"
      autoscaling  = false
      auto_upgrade = true
      node_count   = 3
      machine_type = "e2-medium"
    },
  ]
}

module "gke_auth" {
  source       = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  version      = "21.1.0"
  project_id   = var.gcp_project
  cluster_name = module.gke.name
  location     = module.gke.location
}

resource "local_file" "kubeconfig" {
  content  = module.gke_auth.kubeconfig_raw
  filename = "${path.module}/kubeconfig.yaml"
}
