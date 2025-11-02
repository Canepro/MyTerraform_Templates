variable "project_id" {
  description = "GCP Project ID (REQUIRED)"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Project ID must be 6-30 characters, lowercase alphanumeric and hyphens only"
  }
}

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

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone for VM"
  type        = string
  default     = "us-central1-a"
}

variable "subnet_cidr" {
  description = "CIDR block for subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "machine_type" {
  description = "Machine type (e2-micro is free tier eligible)"
  type        = string
  default     = "e2-micro"
}

variable "ssh_user" {
  description = "SSH username"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "SSH public key content (REQUIRED)"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^ssh-rsa |^ssh-ed25519 |^ecdsa-", var.ssh_public_key))
    error_message = "Must be a valid SSH public key"
  }
}

variable "boot_disk_type" {
  description = "Boot disk type (pd-standard is cheapest)"
  type        = string
  default     = "pd-standard"

  validation {
    condition     = contains(["pd-standard", "pd-balanced", "pd-ssd"], var.boot_disk_type)
    error_message = "Must be pd-standard, pd-balanced, or pd-ssd"
  }
}

variable "boot_disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default     = 20

  validation {
    condition     = var.boot_disk_size >= 10 && var.boot_disk_size <= 2000
    error_message = "Boot disk size must be between 10 and 2000 GB"
  }
}

variable "startup_script" {
  description = "Optional startup script"
  type        = string
  default     = ""
}
