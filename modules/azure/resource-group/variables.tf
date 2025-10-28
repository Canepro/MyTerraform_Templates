variable "name" {
  description = "Name of the resource group"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_()]+$", var.name))
    error_message = "Resource group name must contain only alphanumeric characters, hyphens, underscores, and parentheses"
  }
}

variable "location" {
  description = "Azure region where the resource group will be created"
  type        = string
  default     = "eastus"

  validation {
    condition = contains([
      "eastus", "eastus2", "westus", "westus2", "westus3", "centralus",
      "northcentralus", "southcentralus", "westcentralus",
      "northeurope", "westeurope", "uksouth", "ukwest",
      "southeastasia", "eastasia", "japaneast", "japanwest",
      "australiaeast", "australiasoutheast", "canadacentral", "canadaeast"
    ], var.location)
    error_message = "Location must be a valid Azure region"
  }
}

variable "tags" {
  description = "Tags to apply to the resource group"
  type        = map(string)
  default     = {}
}

