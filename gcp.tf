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

module "gcs_bucket" {
  source          = "terraform-google-modules/cloud-storage/google"
  version         = "3.2.0"
  names           = ["cache"]
  project_id      = var.gcp_project
  location        = var.gcp_region
  prefix          = var.name_prefix
  set_admin_roles = true
  admins          = [format("serviceAccount:%s", module.gke_gitlab_runner_cache_sa.gcp_service_account_email)]
}
