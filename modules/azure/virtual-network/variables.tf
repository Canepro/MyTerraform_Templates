variable "name" {
  description = "Name of the virtual network"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.name))
    error_message = "Virtual network name must contain only alphanumeric characters, hyphens, and underscores"
  }
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where the virtual network will be created"
  type        = string
  default     = "eastus"
}

variable "address_space" {
  description = "Address space for the virtual network (CIDR notation)"
  type        = list(string)
  default     = ["10.0.0.0/16"]

  validation {
    condition     = length(var.address_space) > 0
    error_message = "At least one address space must be specified"
  }
}

variable "dns_servers" {
  description = "List of DNS server IP addresses (empty list uses Azure default DNS)"
  type        = list(string)
  default     = []
}

variable "subnets" {
  description = <<-EOT
    List of subnets to create within the virtual network. Each subnet must have:
    - name: Subnet name
    - address_prefixes: List of address ranges in CIDR notation
    - service_endpoints: (Optional) List of service endpoints (e.g., Microsoft.Storage)
    - delegations: (Optional) List of subnet delegations for Azure services
  EOT
  type = list(object({
    name              = string
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
    delegations = optional(list(object({
      name         = string
      service_name = string
      actions      = optional(list(string), [])
    })), [])
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to the virtual network"
  type        = map(string)
  default     = {}
}

