variable "name" {
  description = "Name of the Key Vault (3-24 chars, alphanumeric and hyphens)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,24}$", var.name))
    error_message = "Key Vault name must be 3-24 characters, alphanumeric and hyphens only"
  }
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where the Key Vault will be created"
  type        = string
  default     = "eastus"
}

variable "sku_name" {
  description = "SKU name for Key Vault (standard or premium)"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "SKU must be 'standard' or 'premium'"
  }
}

variable "soft_delete_retention_days" {
  description = "Number of days to retain soft-deleted vaults (7-90 days)"
  type        = number
  default     = 7

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Soft delete retention must be between 7 and 90 days"
  }
}

variable "purge_protection_enabled" {
  description = "Enable purge protection (prevents permanent deletion)"
  type        = bool
  default     = false
}

variable "enabled_for_deployment" {
  description = "Allow Azure VMs to retrieve certificates"
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "Allow Azure Disk Encryption to retrieve secrets"
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "Allow ARM templates to retrieve secrets"
  type        = bool
  default     = false
}

variable "network_acls_bypass" {
  description = "Services that can bypass network ACLs"
  type        = string
  default     = "AzureServices"

  validation {
    condition     = contains(["AzureServices", "None"], var.network_acls_bypass)
    error_message = "Bypass must be 'AzureServices' or 'None'"
  }
}

variable "network_acls_default_action" {
  description = "Default action for network ACLs (Allow or Deny)"
  type        = string
  default     = "Allow"

  validation {
    condition     = contains(["Allow", "Deny"], var.network_acls_default_action)
    error_message = "Default action must be 'Allow' or 'Deny'"
  }
}

variable "network_acls_ip_rules" {
  description = "List of IP addresses allowed to access Key Vault"
  type        = list(string)
  default     = []
}

variable "network_acls_subnet_ids" {
  description = "List of subnet IDs allowed to access Key Vault"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to the Key Vault"
  type        = map(string)
  default     = {}
}

