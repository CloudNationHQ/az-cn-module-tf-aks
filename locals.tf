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
      linux_os_config        = try(pools.config.linux_os, {
              swap_file_size_mb = 1500
              transparent_huge_page_defrag = "defer+madvise"
              transparent_huge_page_enabled = "madvise"
      })

      kubelet_config         = try(pools.config.kubelet, {
          allowed_unsafe_sysctls    = []
          container_log_max_line    = 1000
          container_log_max_size_mb = 10
          image_gc_high_threshold   = 90
          image_gc_low_threshold    = 70
          pod_max_pid               = 0
          topology_manager_policy   = "best-effort"
      })
      workload_runtime       = try(pools.workload_runtime, null)
      snapshot_id            = try(pools.snapshot_id, null)
      priority               = try(pools.priority, null)
      os_type                = try(pools.os_type, null)
      os_sku                 = try(pools.os_sku, null)
      node_labels            = try(pools.node_labels, {})
      node_taints            = try(pools.node_taints, [])
      mode                   = try(pools.mode, "User")
      max_pods               = try(pools.max_pods, 30)
      kubelet_disk_type      = try(pools.kubelet_disk_type, null)
      eviction_policy        = try(pools.eviction_policy, null)
      enable_fips            = try(pools.enable.fips, false)
      zones                  = try(pools.zones, null)
      enable_node_public_ip  = try(pools.enable.node_public_ip, false)
      enable_auto_scaling    = try(pools.enable.auto_scaling, false)
      enable_host_encryption = try(pools.enable.host_encryption, false)
      availability_zones     = try(pools.availability_zones, [])
      vnet_subnet_id         = try(pools.vnet_subnet_id, null)

      custom_ca_trust        = try(pools.custom_ca_trust, false)
      tags                   = try(pools.tags, {})
      zones                  = try(pools.zones, [])
    }
  ])
}

locals {
  # Managed RBAC
  role_based_access_control_enabled   = try(var.aks.rbac.rbac_enabled, true)
  rbac_aad_managed                    = try(var.aks.rbac.aad_managed, true)
  rbac_aad_admin_group_object_ids     = try(var.aks.rbac.admin_object_id, [data.azurerm_client_config.current.object_id])
  rbac_aad_azure_rbac_enabled         = try(var.aks.rbac.use_rbac_for_cluster_roles, true)
  tenant_id                           = try(var.aks.tenant_id, data.azurerm_subscription.current.tenant_id)

  # Unmanaged RBAC
  rbac_aad_client_app_id              = try(var.aks.rbac.client_app_id, "")
  rbac_aad_server_app_id              = try(var.aks.rbac.server_app_id, "")
  rbac_aad_server_app_secret          = try(var.aks.rbac.server_app_secret, "")
}
