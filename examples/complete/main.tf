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

module "analytics" {
  source = "github.com/cloudnationhq/az-cn-module-tf-law"

  workload    = var.workload
  environment = var.environment

  law = {
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    sku           = "PerGB2018"
    retention     = 90
  }
}

module "kv" {
  source = "github.com/cloudnationhq/az-cn-module-tf-kv"

  workload    = var.workload
  environment = var.environment

  vault = {
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name

    secrets = {
      tls_public_key = {
        aks = {
          algorithm = "RSA"
          rsa_bits  = 2048
        }
      }
    }

    contacts = {
      admin = {
        email = "dummy@cloudnation.nl"
      }
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

    enable = {
      public_access = true
    }

    default_node_pool = {
      vmsize     = "Standard_DS2_v2"
      zones      = [1, 2, 3]
      node_count = 1
    }

    maintenance = {
      allowed = {
        w1 = {
          day   = "Saturday"
          hours = ["1", "6"]
        }
        w2 = {
          day   = "Sunday"
          hours = ["1"]
        }
      }
    }

    workspace = {
      id = module.analytics.law.id
      enable = {
        oms_agent = true
        defender  = true
      }
    }

    profile = {
      network = {
        plugin            = "azure"
        load_balancer_sku = "standard"
        load_balancer = {
          idle_timeout_in_minutes   = 30
          managed_outbound_ip_count = 10
        }
      }
      autoscaler = {
        enable = {
          keda         = true
          vertical_pod = true
        }
        linux = {
          username = "nodeadmin"
          ssh_key  = module.kv.tls_public_key.aks.value
        }
      }
    }
  }
}
