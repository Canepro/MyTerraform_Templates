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
  skip_provider_registration = true
}

# Data source for existing resource group (when use_existing_resource_group is true)
data "azurerm_resource_group" "existing" {
  count = var.use_existing_resource_group ? 1 : 0
  name  = var.existing_resource_group_name
}

# Create new resource group (when use_existing_resource_group is false)
resource "azurerm_resource_group" "this" {
  count    = var.use_existing_resource_group ? 0 : 1
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

# Local values to reference the resource group (existing or new)
locals {
  resource_group_name = var.use_existing_resource_group ? data.azurerm_resource_group.existing[0].name : azurerm_resource_group.this[0].name
  resource_group_location = var.use_existing_resource_group ? data.azurerm_resource_group.existing[0].location : azurerm_resource_group.this[0].location
  resource_group_tags = var.use_existing_resource_group ? data.azurerm_resource_group.existing[0].tags : azurerm_resource_group.this[0].tags
}

# Virtual Network
resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.project_name}"
  resource_group_name = local.resource_group_name
  location            = local.resource_group_location
  address_space       = ["10.0.0.0/16"]

  tags = merge(
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
    },
    var.tags
  )
}

# Subnet
resource "azurerm_subnet" "this" {
  name                 = "snet-vm"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Virtual Machine Module
module "azure_vm" {
  source = "../../../modules/azure/virtual-machine"

  name                = "${var.project_name}-vm"
  project             = var.project_name
  environment         = var.environment
  resource_group_name = local.resource_group_name
  location            = local.resource_group_location
  subnet_id           = azurerm_subnet.this.id

  # OS selection
  os_distribution = var.os_distribution

  # Instance sizing (uses environment defaults if null)
  vm_size                      = var.vm_size
  os_disk_size_gb              = var.os_disk_size_gb
  os_disk_storage_account_type = var.os_disk_type

  # SSH access
  admin_username = var.admin_username
  ssh_public_key = var.ssh_public_key

  # Security
  allowed_ports = var.allowed_ports
  allowed_cidrs = var.allowed_cidrs

  # Static public IP
  enable_public_ip = var.enable_public_ip

  # Auto-shutdown for sandbox safety
  enable_auto_shutdown   = var.enable_auto_shutdown
  auto_shutdown_hours    = var.auto_shutdown_hours
  auto_shutdown_timezone = var.auto_shutdown_timezone

  # Optional features
  enable_managed_identity            = var.enable_managed_identity
  auto_shutdown_notification_enabled = var.auto_shutdown_notification_enabled

  # Software installation
  install_docker  = var.install_docker
  install_jenkins = var.install_jenkins

  tags = var.tags
}
