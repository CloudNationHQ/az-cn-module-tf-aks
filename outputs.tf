output "cluster" {
  value = azurerm_kubernetes_cluster.aks
}

output "subscriptionId" {
  value = data.azurerm_subscription.current.subscription_id
}
