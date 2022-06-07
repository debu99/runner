variable "namespaces" {
  default = {
    gitlab-runner = "gitlab-runner"
    promethues    = "monitoring"
  }
}

variable "gitlab_runner_min_replica" {
  default = 1
}

variable "gitlab_runner_max_replica" {
  default = 5
}

variable "gitlab_runner_concurrent" {
  default = 2
}

variable "gcp_cred_json" {
  type    = string
  default = "serviceaccount.json"
}

variable "gcp_project" {
  type        = string
  description = "The GCP project to deploy the runner into."
}

variable "gcp_region" {
  description = "The GCP region to deploy the runner into."
}

variable "gcp_zone" {
  type        = string
  description = "The GCP zone to deploy the runner into."
}

variable "name_prefix" {
  type        = string
  default     = "gitlab-ci"
  description = "The prefix to apply to all GCP resource names (e.g. <prefix>-runner, <prefix>-worker-1)."
}

variable "gcs_force_destroy" {
  default     = false
}

variable "runner_registration_token" {
  type = string
}