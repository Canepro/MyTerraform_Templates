terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

resource "azurerm_network_interface" "this" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.enable_public_ip ? azurerm_public_ip.this[0].id : null
  }

  tags = var.tags
}

resource "azurerm_public_ip" "this" {
  count = var.enable_public_ip ? 1 : 0

  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "this" {
  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.this.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_storage_account_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  # Auto-shutdown schedule (optional, helps control costs)
  dynamic "identity" {
    for_each = var.enable_managed_identity ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }

  tags = var.tags
}

# Optional: Auto-shutdown schedule
resource "azurerm_dev_test_global_vm_shutdown_schedule" "this" {
  count = var.enable_auto_shutdown ? 1 : 0

  virtual_machine_id = azurerm_linux_virtual_machine.this.id
  location           = var.location
  enabled            = true

  daily_recurrence_time = var.auto_shutdown_time
  timezone              = var.auto_shutdown_timezone

  notification_settings {
    enabled = var.auto_shutdown_notification_enabled
  }

  tags = var.tags
}

