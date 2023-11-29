# Kubernetes Service

This terraform module simplifies the creation and management of kubernetes resources on Azure, offering customizable options for cluster, node pool, network settings, and add-ons to ensure efficient deployment of kubernetes clusters.

## Goals

The main objective is to create a more logic data structure, achieved by combining and grouping related resources together in a complex object.

The structure of the module promotes reusability. It's intended to be a repeatable component, simplifying the process of building diverse workloads and platform accelerators consistently.

A primary goal is to utilize keys and values in the object that correspond to the REST API's structure. This enables us to carry out iterations, increasing its practical value as time goes on.

A last key goal is to separate logic from configuration in the module, thereby enhancing its scalability, ease of customization, and manageability.

## Features

- enhanced adaptability with support for multiple node pools
- utilization of terratest for robust validation
- providing support for integration with container registries, enhancing the efficiency of image management

The below examples shows the usage when consuming the module:

## Usage: simple

```hcl
module "aks" {
  source = "github.com/cloudnationhq/az-cn-module-tf-aks"

  aks = {
    name                = module.naming.kubernetes_cluster.name_unique
    location            = module.rg.groups.demo.location
    resourcegroup       = module.rg.groups.demo.name
    node_resource_group = "${module.rg.groups.demo.name}-node"

    default_node_pool = {
      vmsize     = "Standard_DS2_v2"
      node_count = 1
    }

    profile = {
      linux = {
        username = "nodeadmin"
        ssh_key  = module.kv.tls_public_keys.aks.value
      }
    }
  }
}
```

## Usage: node pools

```hcl
module "aks" {
  source = "github.com/cloudnationhq/az-cn-module-tf-aks"

  aks = {
    name                = module.naming.kubernetes_cluster.name_unique
    location            = module.rg.groups.demo.location
    resourcegroup       = module.rg.groups.demo.name
    node_resource_group = "${module.rg.groups.demo.name}-node"

    default_node_pool = {
      node_count = 1
      vmsize     = "Standard_DS2_v2"
    }

    profile = {
      linux = {
        username = "nodeadmin"
        ssh_key  = module.kv.tls_public_keys.aks.value
      }
    }

    node_pools = {
      pool1 = { vmsize = "Standard_DS2_v2", node_count = 1, max_surge = 50 }
      pool2 = { vmsize = "Standard_DS2_v2", node_count = 1, max_surge = 50 }
    }
  }
}
```

## Usage: container registry

```hcl
module "aks" {
  source = "github.com/cloudnationhq/az-cn-module-tf-aks"

  aks = {
    name                = module.naming.kubernetes_cluster.name_unique
    location            = module.rg.groups.demo.location
    resourcegroup       = module.rg.groups.demo.name
    node_resource_group = "${module.rg.groups.demo.name}-node"

    registry = {
      attach = true, role_assignment_scope = module.registry.acr.id
    }

    profile = {
      linux = {
        username = "nodeadmin"
        ssh_key  = module.kv.tls_public_keys.aks.value
      }
    }

    default_node_pool = {
      vmsize     = "Standard_DS2_v2"
      node_count = 1
    }
  }
}
```

## Data Sources

| Name | Type |
| :-- | :-- |
| [azurerm_subscription](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | datasource |

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
| `cluster` | describes aks related configuration | object | yes |
| `naming` | contains naming convention | string | yes |

## Outputs

| Name | Description |
| :-- | :-- |
| `aks` | contains all aks configuration |
| `subscriptionId` | contains the current subsriptionId |

## Testing

As a prerequirement, please ensure that both go and terraform are properly installed on your system.

The [Makefile](Makefile) includes two distinct variations of tests. The first one is designed to deploy different usage scenarios of the module. These tests are executed by specifying the TF_PATH environment variable, which determines the different usages located in the example directory.

To execute this test, input the command ```make test TF_PATH=simple```, substituting simple with the specific usage you wish to test.

The second variation is known as a extended test. This one performs additional checks and can be executed without specifying any parameters, using the command ```make test_extended```.

Both are designed to be executed locally and are also integrated into the github workflow.

Each of these tests contributes to the robustness and resilience of the module. They ensure the module performs consistently and accurately under different scenarios and configurations.

## Notes

Using a dedicated module, we've developed a naming convention for resources that's based on specific regular expressions for each type, ensuring correct abbreviations and offering flexibility with multiple prefixes and suffixes

Full examples detailing all usages, along with integrations with dependency modules, are located in the examples directory

## Authors

Module is maintained by [these awesome contributors](https://github.com/cloudnationhq/az-cn-module-tf-aks/graphs/contributors).

## License

MIT Licensed. See [LICENSE](https://github.com/cloudnationhq/az-cn-module-tf-aks/blob/main/LICENSE) for full details.


## References

- [Documentation](https://learn.microsoft.com/en-us/azure/aks)
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/aks)
