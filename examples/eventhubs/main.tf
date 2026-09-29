module "naming" {
  source  = "codectl/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "dev"]
}

module "regions" {
  source  = "codectl/locations/azure"
  version = "~> 1.0"

  location = {
    primary = "westeurope"
  }
}

module "rg" {
  source  = "codectl/rg/azure"
  version = "~> 1.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = module.regions.location.primary.name
    }
  }
}

module "eventhub" {
  source  = "codectl/evh/azure"
  version = "~> 1.0"

  namespace = {
    name                = module.naming.eventhub_namespace.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    eventhubs = {
      alerts = {
        partition_count   = 2
        message_retention = 2
        authorization_rules = {
          users = {
            listen = true
          }
          admins = {
            listen = true
            send   = true
            manage = true
          }
        }
      }
      defaults = {
        partition_count = 2
      }
      retention-delete = {
        partition_count = 2
        retention_description = {
          cleanup_policy          = "Delete"
          retention_time_in_hours = 168
        }
      }
      retention-compact = {
        partition_count = 2
        retention_description = {
          cleanup_policy                    = "Compact"
          tombstone_retention_time_in_hours = 24
        }
      }
      metrics = {
        partition_count   = 4
        message_retention = 3
        authorization_rules = {
          users = {
            listen = true
          }
          admins = {
            listen = true
            send   = true
            manage = true
          }
        }
      }
    }
  }
}
