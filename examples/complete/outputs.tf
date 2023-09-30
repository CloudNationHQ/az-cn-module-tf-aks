output "aks" {
  value     = module.aks.cluster
  sensitive = true
}

output "subscriptionId" {
  value = module.aks.subscriptionId
}
