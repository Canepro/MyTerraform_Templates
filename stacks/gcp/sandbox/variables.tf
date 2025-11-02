variable "project_id" {
  description = "GCP Project ID"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Project ID must be 6-30 characters, lowercase alphanumeric and hyphens"
  }
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "demo"

  validation {
    condition     = can(regex("^[a-z0-9]{2,20}$", var.prefix))
    error_message = "Prefix must be 2-20 characters, lowercase alphanumeric only"
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
  description = "Optional suffix for resource names"
  type        = string
  default     = ""
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"

  validation {
    condition = contains([
      "us-central1", "us-east1", "us-west1", "us-west3",
      "europe-west1", "europe-west4", "asia-southeast1"
    ], var.region)
    error_message = "Must be a valid GCP region"
  }
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "engineering"
}

variable "custom_tags" {
  description = "Additional custom tags"
  type        = map(string)
  default     = {}
}

# Network configuration
variable "subnets" {
  description = "List of subnets to create"
  type = list(object({
    name   = string
    cidr   = string
    region = string
  }))
  default = [
    {
      name   = "subnet-default"
      cidr   = "10.0.1.0/24"
      region = "us-central1"
    }
  ]
}

