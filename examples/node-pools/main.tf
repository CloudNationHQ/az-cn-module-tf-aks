provider "azurerm" {
  features {}
}

module "rg" {
  source = "github.com/cloudnationhq/az-cn-module-tf-rg"

  environment = var.environment

  groups = {
    demo = {
      region = "westeurope"
    }
  }
}

module "aks" {
  source = "../../"

  workload    = var.workload
  environment = var.environment

  aks = {
    location            = module.rg.groups.demo.location
    resourcegroup       = module.rg.groups.demo.name
    node_resource_group = "${module.rg.groups.demo.name}-node"
    channel_upgrade     = "stable"

    default_node_pool = {
      node_count = 1
      vmsize     = "Standard_DS2_v2"
    }

    node_pools = {
      pool1 = { vmsize = "Standard_DS2_v2", node_count = 1, max_surge = 50 }
      pool2 = { vmsize = "Standard_DS2_v2", node_count = 1, max_surge = 50 }
    }
  }
}
