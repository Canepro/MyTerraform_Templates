variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
  default     = "quickvm"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,30}$", var.project_name))
    error_message = "Project name must be 1-30 characters, lowercase alphanumeric and hyphens only"
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, test, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod", "sandbox"], var.environment)
    error_message = "Environment must be dev, test, prod, or sandbox"
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "vm_size" {
  description = "VM size (Standard_B1s is the cheapest at ~$9/month)"
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
  description = "SSH public key content (required)"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^ssh-rsa |^ssh-ed25519 |^ecdsa-", var.ssh_public_key))
    error_message = "Must be a valid SSH public key"
  }
}

variable "os_disk_type" {
  description = "OS disk storage type (Standard_LRS is cheapest)"
  type        = string
  default     = "Standard_LRS"

  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS"], var.os_disk_type)
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

variable "enable_auto_shutdown" {
  description = "Enable auto-shutdown schedule (recommended for cost savings)"
  type        = bool
  default     = false
}

variable "auto_shutdown_time" {
  description = "Auto-shutdown time (24-hour format, e.g., '1900' for 7 PM)"
  type        = string
  default     = "1900"
}

variable "auto_shutdown_timezone" {
  description = "Timezone for auto-shutdown"
  type        = string
  default     = "UTC"
}
