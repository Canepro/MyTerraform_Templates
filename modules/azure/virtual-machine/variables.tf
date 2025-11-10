variable "name" {
  description = "Name of the virtual machine"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,64}$", var.name))
    error_message = "VM name must be 1-64 characters, alphanumeric and hyphens only"
  }
}

variable "project" {
  description = "Project tag applied to all resources"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]{1,64}$", var.project))
    error_message = "Project must be 1-64 characters using alphanumeric, hyphen, or underscore"
  }
}

variable "environment" {
  description = "Deployment environment (dev, training, prod)"
  type        = string
  default     = "training"

  validation {
    condition     = contains(["dev", "training", "prod"], var.environment)
    error_message = "Environment must be one of dev, training, or prod"
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
  description = "VM size. Defaults are derived from the environment profile when null."
  type        = string
  default     = null
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB. Defaults are derived from the environment profile when null."
  type        = number
  default     = null

  validation {
    condition     = var.os_disk_size_gb == null || (var.os_disk_size_gb >= 30 && var.os_disk_size_gb <= 2048)
    error_message = "OS disk size must be between 30 and 2048 GB"
  }
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

variable "os_distribution" {
  description = "Base operating system to deploy (ubuntu or azure-linux)"
  type        = string
  default     = "ubuntu"

  validation {
    condition     = contains(["ubuntu", "azure-linux"], var.os_distribution)
    error_message = "os_distribution must be one of: ubuntu, azure-linux"
  }
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

variable "allowed_ports" {
  description = "List of TCP ports to allow inbound from allowed_cidrs."
  type        = list(number)
  default     = [22, 80, 8080]

  validation {
    condition     = length([for port in var.allowed_ports : port if port > 0 && port <= 65535]) == length(var.allowed_ports)
    error_message = "Allowed ports must be between 1 and 65535"
  }
}

variable "allowed_cidrs" {
  description = "CIDR blocks allowed to access the VM."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_public_ip" {
  description = "Provision a static public IP for the VM"
  type        = bool
  default     = true
}

variable "enable_managed_identity" {
  description = "Enable system-assigned managed identity"
  type        = bool
  default     = false
}

variable "enable_auto_shutdown" {
  description = "Enable auto-shutdown schedule (recommended for sandbox/training)"
  type        = bool
  default     = true
}

variable "auto_shutdown_hours" {
  description = "Number of hours after provisioning before issuing a shutdown"
  type        = number
  default     = 4

  validation {
    condition     = var.auto_shutdown_hours >= 1 && var.auto_shutdown_hours <= 24
    error_message = "Auto shutdown hours must be between 1 and 24"
  }
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

variable "install_docker" {
  description = "Install Docker on the VM"
  type        = bool
  default     = true
}

variable "install_jenkins" {
  description = "Install Jenkins on the VM (requires Docker if set to true)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to merge into all resources"
  type        = map(string)
  default     = {}
}

