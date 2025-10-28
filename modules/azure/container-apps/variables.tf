variable "name" {
  description = "Container App name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "container_name" {
  description = "Container name"
  type        = string
  default     = "app"
}

variable "container_image" {
  description = "Container image (e.g., mcr.microsoft.com/azuredocs/containerapps-helloworld:latest)"
  type        = string
}

variable "cpu" {
  description = "CPU cores (0.25, 0.5, 0.75, 1.0, etc)"
  type        = number
  default     = 0.25
}

variable "memory" {
  description = "Memory in Gi (0.5, 1.0, 1.5, etc)"
  type        = string
  default     = "0.5Gi"
}

variable "min_replicas" {
  description = "Minimum replicas (0 for scale-to-zero)"
  type        = number
  default     = 0
}

variable "max_replicas" {
  description = "Maximum replicas"
  type        = number
  default     = 1
}

variable "enable_ingress" {
  description = "Enable HTTP ingress"
  type        = bool
  default     = false
}

variable "ingress_external_enabled" {
  description = "Enable external ingress (public)"
  type        = bool
  default     = false
}

variable "ingress_target_port" {
  description = "Target port for ingress"
  type        = number
  default     = 80
}

variable "env_vars" {
  description = "Environment variables"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}

