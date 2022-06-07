/*
module "gke_gitlab_runner_cache_sa" {
  source  = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  version = "21.1.0"

  project_id          = var.gcp_project
  use_existing_k8s_sa = true
  annotate_k8s_sa     = false
  name                = "gitlab-runner-cache"
  k8s_sa_name         = "gitlab-runner"
  namespace           = "gitlab-runner"
}
*/

module "service_account" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "4.1.1"
  project_id = var.gcp_project
  prefix     = var.name_prefix
  names      = ["sa"]
  project_roles = [
    "${var.gcp_project}=>roles/storage.admin",
  ]
  generate_keys = true
}

module "gcs_bucket" {
  source          = "terraform-google-modules/cloud-storage/google"
  version         = "3.2.0"
  names           = ["cache"]
  project_id      = var.gcp_project
  location        = var.gcp_region
  prefix          = var.name_prefix
  set_admin_roles = true
  force_destroy   = {force_destroy = var.gcs_force_destroy}
  admins          = [format("serviceAccount:%s", module.service_account.email)]
}

resource "local_file" "gcp_credential" {
  content  = module.service_account.key
  filename = "${path.module}/gcp_credential.json"
}