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

variable "bucket_versioning" {
  description = "Boolean used to enable versioning on the cache bucket, false by default."
  type        = bool
  default     = false
}

variable "bucket_storage_class" {
  description = "The cache storage class"
  default     = "STANDARD"
}

variable "bucket_expiration_days" {
  description = "Number of days before cache objects expires."
  type        = number
  default     = 30
}

variable "bucket_labels" {
  description = "labels to apply to the storage bucket"
  type        = map(string)
  default     = {}
}

variable "runner_registration_token" {
  type = string
}