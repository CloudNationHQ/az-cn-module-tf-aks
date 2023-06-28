# Kubernetes Service

This terraform module simplifies the creation and management of kubernetes resources on Azure, offering customizable options for cluster, node pool, network settings, and add-ons to ensure efficient deployment of kubernetes clusters.

The below features are made available:

- multiple node pools
- terratest is used to validate different integrations
- container registry integration

The below examples shows the usage when consuming the module:

## Usage: simple

```hcl
module "aks" {
  source = "github.com/cloudnationhq/az-cn-module-tf-aks"

  workload       = var.workload
  environment    = var.environment
  location_short = module.region.location_short

  aks = {
    location            = module.rg.group.location
    resourcegroup       = module.rg.group.name
    node_resource_group = "${module.global.groups.demo.name}-node"

    default_node_pool = {
      vmsize     = "Standard_DS2_v2"
      zones      = [1, 2, 3]
      node_count = 1
    }

    profile = {
      linux = {
        username = "nodeadmin"
        ssh_key  = module.kv.tls_public_key.aks.value
      }
    }
  }
  depends_on = [module.rg]
}
```

## Usage: node pools

```hcl
module "aks" {
  source = "github.com/cloudnationhq/az-cn-module-tf-aks"

  workload       = var.workload
  environment    = var.environment
  location_short = module.regions.location_short

  aks = {
    location            = module.rg.group.location
    resourcegroup       = module.rg.group.name
    node_resource_group = "${module.rg.group.name}-node"
    channel_upgrade     = "stable"
    dns_prefix          = "aksdemo"

    default_node_pool = {
      node_count = 1
      vmsize           = "Standard_DS2_v2"
      zones            = [1, 2, 3]
    }

    node_pools = {
      pool1 = { vmsize = "Standard_DS2_v2", node_count = 1, max_surge = 50 }
      pool2 = { vmsize = "Standard_DS2_v2", node_count = 1, max_surge = 50 }
    }
  }
  depends_on = [module.rg]
}


```

## Resources

| Name | Type |
| :-- | :-- |
| [azurerm_kubernetes_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_kubernetes_cluster_extension](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_extension) | resource |

## Inputs

| Name | Description | Type | Required |
| :-- | :-- | :-- | :-- |
| `aks` | describes aks related configuration | object | yes |
| `workload` | contains the workload name used, for naming convention	| string | yes |
| `environment` | contains shortname of the environment used for naming convention	| string | yes |

## Outputs

| Name | Description |
| :-- | :-- |
| `aks` | contains all aks configuration |

## Testing
This GitHub repository features a [Makefile](./Makefile) tailored for testing various configurations. Each test target corresponds to different example use cases provided within the repository.

Before running these tests, ensure that both Go and Terraform are installed on your system. To execute a specific test, use the following command ```make <test-target>```

## Authors

Module is maintained by [these awesome contributors](https://github.com/cloudnationhq/az-cn-module-tf-aks/graphs/contributors).

## License

MIT Licensed. See [LICENSE](https://github.com/aztfmods/module-azurerm-aks/blob/main/LICENSE) for full details.

## References

- [Documentation](https://learn.microsoft.com/en-us/azure/aks)
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/aks)


