variable "prefix" {
  description = "Prefix for resource names (e.g., myapp, project name)"
  type        = string
  default     = "demo"

  validation {
    condition     = can(regex("^[a-z0-9]{2,10}$", var.prefix))
    error_message = "Prefix must be 2-10 characters, lowercase alphanumeric only"
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "sandbox"

  validation {
    condition     = var.environment == "sandbox"
    error_message = "This stack is for sandbox environment only"
  }
}

variable "suffix" {
  description = "Optional suffix for resource names (e.g., 001, east, west)"
  type        = string
  default     = ""
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"

  validation {
    condition = contains([
      "eastus", "eastus2", "westus", "westus2", "westus3", "centralus",
      "northeurope", "westeurope"
    ], var.location)
    error_message = "Location must be a valid, cost-effective Azure region"
  }
}

variable "cost_center" {
  description = "Cost center for billing purposes"
  type        = string
  default     = "engineering"
}

variable "custom_tags" {
  description = "Additional custom tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Network configuration
variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_default_prefix" {
  description = "Address prefix for the default subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_app_prefix" {
  description = "Address prefix for the application subnet"
  type        = string
  default     = "10.0.2.0/24"
}

