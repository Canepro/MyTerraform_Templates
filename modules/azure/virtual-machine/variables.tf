variable "name" {
  description = "Name of the virtual machine"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,64}$", var.name))
    error_message = "VM name must be 1-64 characters, alphanumeric and hyphens only"
  }
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where the VM will be created"
  type        = string
  default     = "eastus"
}

variable "subnet_id" {
  description = "Subnet ID where the VM will be deployed"
  type        = string
}

variable "vm_size" {
  description = "VM size (Standard_B1s is cheapest)"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,63}$", var.admin_username))
    error_message = "Admin username must start with lowercase letter, 1-64 chars"
  }
}

variable "ssh_public_key" {
  description = "SSH public key for authentication (required)"
  type        = string

  validation {
    condition     = can(regex("^ssh-rsa |^ssh-ed25519 |^ecdsa-", var.ssh_public_key))
    error_message = "Must be a valid SSH public key (ssh-rsa, ssh-ed25519, or ecdsa)"
  }
}

variable "enable_public_ip" {
  description = "Enable public IP address for the VM"
  type        = bool
  default     = false
}

variable "os_disk_storage_account_type" {
  description = "Storage account type for OS disk (Standard_LRS is cheapest)"
  type        = string
  default     = "Standard_LRS"

  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS"], var.os_disk_storage_account_type)
    error_message = "Must be Standard_LRS, StandardSSD_LRS, or Premium_LRS"
  }
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 30

  validation {
    condition     = var.os_disk_size_gb >= 30 && var.os_disk_size_gb <= 2048
    error_message = "OS disk size must be between 30 and 2048 GB"
  }
}

# Ubuntu 22.04 LTS by default
variable "image_publisher" {
  description = "OS image publisher"
  type        = string
  default     = "Canonical"
}

variable "image_offer" {
  description = "OS image offer"
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}

variable "image_sku" {
  description = "OS image SKU"
  type        = string
  default     = "22_04-lts-gen2"
}

variable "image_version" {
  description = "OS image version"
  type        = string
  default     = "latest"
}

variable "enable_managed_identity" {
  description = "Enable system-assigned managed identity"
  type        = bool
  default     = false
}

variable "enable_auto_shutdown" {
  description = "Enable auto-shutdown schedule (recommended for dev/test)"
  type        = bool
  default     = false
}

variable "auto_shutdown_time" {
  description = "Auto-shutdown time (24-hour format, e.g., '1900' for 7 PM)"
  type        = string
  default     = "1900"
}

variable "auto_shutdown_timezone" {
  description = "Timezone for auto-shutdown (e.g., 'UTC', 'Eastern Standard Time')"
  type        = string
  default     = "UTC"
}

variable "auto_shutdown_notification_enabled" {
  description = "Enable auto-shutdown notifications"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the VM and related resources"
  type        = map(string)
  default     = {}
}

