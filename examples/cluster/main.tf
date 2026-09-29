module "naming" {
  source  = "codectl/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "prd"]
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

module "eventhubs" {
  source  = "codectl/evh/azure"
  version = "~> 1.0"

  for_each = local.namespaces

  namespace = each.value
}

module "cluster" {
  source  = "codectl/evh/azure//modules/cluster"
  version = "~> 1.0"

  resource_group_name = module.rg.groups.demo.name
  location            = module.rg.groups.demo.location

  cluster = {
    name = "evhc-demo-dev"
    sku  = "Dedicated_1"
  }
}
