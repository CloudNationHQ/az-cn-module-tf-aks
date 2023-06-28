output "aks" {
  value = azurerm_kubernetes_cluster.aks
}

# output "merged_ids" {
#   value = values(azurerm_kubernetes_cluster.aks)[*].id
# }
