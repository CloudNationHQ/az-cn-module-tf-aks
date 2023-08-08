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

module "registry" {
  source = "github.com/cloudnationhq/az-cn-module-tf-acr"

  workload    = var.workload
  environment = var.environment

  registry = {
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    sku           = "Premium"
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

    registry = {
      attach = true, role_assignment_scope = module.registry.acr.id
    }

    default_node_pool = {
      vmsize     = "Standard_DS2_v2"
      node_count = 1
    }
  }
}
