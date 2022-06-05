provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "google" {
  credentials = file("./serviceaccount.json")
  project     = var.gcp_project
  region      = var.gcp_region
  zone        = var.gcp_zone
}

provider "kubectl" {
  config_path = "~/.kube/config"
}

terraform {
  required_version = ">= 1.0.7"

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "> 1.7.0"
    }
  }
}
