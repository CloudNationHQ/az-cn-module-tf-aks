locals {
  aks_pools = flatten([
    for pools_key, pools in try(var.aks.node_pools, {}) : {
      pools_key              = pools_key
      vmsize                 = pools.vmsize
      node_count             = try(pools.node_count, 1)
      max_count              = try(pools.max_count, 0)
      min_count              = try(pools.min_count, 0)
      max_surge              = pools.max_surge
      poolname               = "aks${pools_key}"
      aks_cluster_id         = azurerm_kubernetes_cluster.aks.id
      linux_os_config        = try(pools.config.linux_os, {})
      kubelet_config         = try(pools.config.kubelet, {})
      workload_runtime       = try(pools.workload_runtime, null)
      snapshot_id            = try(pools.snapshot_id, null)
      priority               = try(pools.priority, null)
      os_type                = try(pools.os_type, null)
      os_sku                 = try(pools.os_sku, null)
      node_tains             = try(pools.node_tains, null)
      node_labels            = try(pools.node_labels, null)
      mode                   = try(pools.mode, "User")
      max_pods               = try(pools.max_pods, 30)
      kubelet_disk_type      = try(pools.kubelet_disk_type, null)
      eviction_policy        = try(pools.eviction_policy, null)
      enable_fips            = try(pools.enable.fips, false)
      zones                  = try(pools.zones, null)
      enable_node_public_ip  = try(pools.enable.node_public_ip, false)
      enable_auto_scaling    = try(pools.enable.auto_scaling, false)
      enable_host_encryption = try(pools.enable.host_encryption, false)
      node_taints            = try(pools.node_taints, null)
      node_labels            = try(pools.node_labels, null)
      availability_zones     = try(pools.availability_zones, [])
    }
  ])
}
