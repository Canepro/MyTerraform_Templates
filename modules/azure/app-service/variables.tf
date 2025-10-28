variable "name" {
  description = "Name of the App Service (must be globally unique)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "sku_name" {
  description = "SKU name (F1=free, B1=basic ~$13/month, S1=standard ~$70/month)"
  type        = string
  default     = "F1"

  validation {
    condition     = contains(["F1", "B1", "B2", "B3", "S1", "S2", "S3", "P1v2", "P2v2", "P3v2"], var.sku_name)
    error_message = "Invalid SKU name"
  }
}

variable "always_on" {
  description = "Keep app always loaded (not available on F1 free tier)"
  type        = bool
  default     = false
}

variable "application_stack" {
  description = "Application runtime stack configuration"
  type = object({
    docker_image     = optional(string)
    docker_image_tag = optional(string)
    node_version     = optional(string)
    python_version   = optional(string)
    dotnet_version   = optional(string)
  })
  default = null
}

variable "app_settings" {
  description = "Application settings (environment variables)"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}

