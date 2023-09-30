provider "azurerm" {
  features {}
}

module "naming" {
  source = "github.com/cloudnationhq/az-cn-module-tf-naming"

  suffix = ["demo", "dev"]
}

module "rg" {
  source = "github.com/cloudnationhq/az-cn-module-tf-rg"

  groups = {
    demo = {
      name   = module.naming.resource_group.name
      region = "westeurope"
    }
  }
}

module "kv" {
  source = "github.com/cloudnationhq/az-cn-module-tf-kv"

  naming = local.naming

  vault = {
    name          = module.naming.key_vault.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name

    secrets = {
      random_string = {
        secret1 = {
          length  = 24
          special = false
        }
      }
      tls_keys = {
        aks = {
          algorithm = "RSA"
          rsa_bits  = 2048
        }
      }
    }
  }
}

module "aks" {
  source = "../../"

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
