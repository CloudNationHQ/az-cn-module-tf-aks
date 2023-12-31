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

module "analytics" {
  source = "github.com/cloudnationhq/az-cn-module-tf-law"

  law = {
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    sku           = "PerGB2018"
    retention     = 90
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
      vmsize     = "Standard_DS2_v2"
      node_count = 1
    }

    maintenance_auto_upgrade = {
      disallowed = {
        w1 = {
          start = "2023-08-02T15:04:05Z"
          end   = "2023-08-05T20:04:05Z"
        }
      }

      config = {
        frequency   = "RelativeMonthly"
        interval    = "2"
        duration    = "5"
        week_index  = "First"
        day_of_week = "Tuesday"
        start_time  = "00:00"
      }
    }

    maintenance_node_os = {
      disallowed = {
        w1 = {
          start = "2023-08-02T15:04:05Z"
          end   = "2023-08-05T20:04:05Z"
        }
      }

      config = {
        frequency   = "Weekly"
        interval    = "2"
        duration    = "5"
        day_of_week = "Monday"
        start_time  = "00:00"
      }
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

      linux = {
        username = "nodeadmin"
        ssh_key  = module.kv.tls_public_keys.aks.value
      }
    }
  }
}
