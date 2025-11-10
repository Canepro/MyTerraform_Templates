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
  description = "Environment profile (dev, training, prod)"
  type        = string
  default     = "training"

  validation {
    condition     = contains(["dev", "training", "prod"], var.environment)
    error_message = "Environment must be dev, training, or prod"
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "os_distribution" {
  description = "Operating system (ubuntu or azure-linux)"
  type        = string
  default     = "ubuntu"

  validation {
    condition     = contains(["ubuntu", "azure-linux"], var.os_distribution)
    error_message = "os_distribution must be ubuntu or azure-linux"
  }
}

variable "vm_size" {
  description = "Azure VM size (null uses environment default)"
  type        = string
  default     = null
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB (null uses environment default)"
  type        = number
  default     = null

  validation {
    condition     = var.os_disk_size_gb == null || (var.os_disk_size_gb >= 30 && var.os_disk_size_gb <= 2048)
    error_message = "OS disk size must be between 30 and 2048 GB"
  }
}

variable "os_disk_type" {
  description = "OS disk storage type (Standard_LRS recommended)"
  type        = string
  default     = "Standard_LRS"

  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS"], var.os_disk_type)
    error_message = "Must be Standard_LRS, StandardSSD_LRS, or Premium_LRS"
  }
}

variable "admin_username" {
  description = "Admin username for SSH access"
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

variable "allowed_ports" {
  description = "TCP ports to allow inbound"
  type        = list(number)
  default     = [22, 80, 8080]

  validation {
    condition     = length([for port in var.allowed_ports : port if port > 0 && port <= 65535]) == length(var.allowed_ports)
    error_message = "Allowed ports must be between 1 and 65535"
  }
}

variable "allowed_cidrs" {
  description = "CIDR blocks allowed to access the VM"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_public_ip" {
  description = "Allocate a static public IP"
  type        = bool
  default     = true
}

variable "enable_auto_shutdown" {
  description = "Enable 4-hour auto-shutdown helper"
  type        = bool
  default     = true
}

variable "auto_shutdown_hours" {
  description = "Hours before auto-shutdown triggers"
  type        = number
  default     = 4

  validation {
    condition     = var.auto_shutdown_hours > 0 && var.auto_shutdown_hours <= 24
    error_message = "Auto-shutdown hours must be between 1 and 24"
  }
}

variable "auto_shutdown_timezone" {
  description = "Timezone for auto-shutdown schedule"
  type        = string
  default     = "UTC"
}

variable "enable_managed_identity" {
  description = "Enable system-assigned managed identity"
  type        = bool
  default     = false
}

variable "auto_shutdown_notification_enabled" {
  description = "Enable auto-shutdown email notifications"
  type        = bool
  default     = false
}

variable "install_docker" {
  description = "Install Docker on the VM"
  type        = bool
  default     = true
}

variable "install_jenkins" {
  description = "Install Jenkins on the VM"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

