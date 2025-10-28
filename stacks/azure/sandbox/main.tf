terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}

  # Skip automatic resource provider registration to avoid conflicts
  # Resource providers will be registered on-demand when needed
  skip_provider_registration = true
}

# Common naming convention
module "naming" {
  source = "../../../modules/common/naming"

  prefix      = var.prefix
  environment = var.environment
  suffix      = var.suffix
}

# Common tags
module "tags" {
  source = "../../../modules/common/tags"

  environment = var.environment
  managed_by  = "terraform"
  cost_center = var.cost_center
  custom_tags = var.custom_tags
}

# Resource Group
module "resource_group" {
  source = "../../../modules/azure/resource-group"

  name     = module.naming.resource_group
  location = var.location
  tags     = module.tags.tags
}

# Storage Account
module "storage_account" {
  source = "../../../modules/azure/storage-account"

  name                     = module.naming.storage_account
  resource_group_name      = module.resource_group.name
  location                 = module.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  access_tier              = "Hot"

  # Security: No public blob access
  allow_public_access = false

  tags = module.tags.tags
}

# Virtual Network with Subnets
module "virtual_network" {
  source = "../../../modules/azure/virtual-network"

  name                = module.naming.virtual_network
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  address_space       = var.vnet_address_space

  subnets = [
    {
      name             = "snet-default"
      address_prefixes = [var.subnet_default_prefix]
      service_endpoints = [
        "Microsoft.Storage",
        "Microsoft.KeyVault"
      ]
    },
    {
      name             = "snet-app"
      address_prefixes = [var.subnet_app_prefix]
      service_endpoints = [
        "Microsoft.Storage"
      ]
    }
  ]

  tags = module.tags.tags
}

