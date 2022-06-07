output "service_account_key" {
  value = module.service_account.key
  sensitive = true
}

output "kubeconfig" {
  value     = module.gke_auth.kubeconfig_raw
  sensitive = true
}