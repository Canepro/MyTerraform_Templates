variable "name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where the AKS cluster will be created"
  type        = string
  default     = "eastus"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster (defaults to cluster name)"
  type        = string
  default     = ""
}

variable "kubernetes_version" {
  description = "Kubernetes version (e.g., '1.28', leave empty for latest stable)"
  type        = string
  default     = null
}

variable "node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 1

  validation {
    condition     = var.node_count >= 1 && var.node_count <= 10
    error_message = "Node count must be between 1 and 10"
  }
}

variable "node_vm_size" {
  description = "VM size for nodes (Standard_B2s is cost-effective for dev)"
  type        = string
  default     = "Standard_B2s"
}

variable "vnet_subnet_id" {
  description = "Subnet ID for AKS nodes"
  type        = string
}

variable "enable_auto_scaling" {
  description = "Enable auto-scaling for the node pool"
  type        = bool
  default     = false
}

variable "min_node_count" {
  description = "Minimum node count for auto-scaling"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum node count for auto-scaling"
  type        = number
  default     = 3
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 30
}

variable "network_policy" {
  description = "Network policy to use (azure, calico, or null)"
  type        = string
  default     = "azure"
}

variable "service_cidr" {
  description = "CIDR for Kubernetes services"
  type        = string
  default     = "10.240.0.0/16"
}

variable "dns_service_ip" {
  description = "IP address for Kubernetes DNS service"
  type        = string
  default     = "10.240.0.10"
}

variable "tags" {
  description = "Tags to apply to the AKS cluster"
  type        = map(string)
  default     = {}
}

