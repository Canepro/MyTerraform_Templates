variable "prefix" {
  description = "Prefix for resource names (e.g., app name, project name)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{2,10}$", var.prefix))
    error_message = "Prefix must be 2-10 characters, lowercase alphanumeric only"
  }
}

variable "environment" {
  description = "Environment name (e.g., sandbox, dev, prod)"
  type        = string

  validation {
    condition     = contains(["sandbox", "dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: sandbox, dev, staging, prod"
  }
}

variable "suffix" {
  description = "Optional suffix for resource names (e.g., 001, data, web)"
  type        = string
  default     = ""

  validation {
    condition     = var.suffix == "" || can(regex("^[a-z0-9]{1,6}$", var.suffix))
    error_message = "Suffix must be empty or 1-6 characters, lowercase alphanumeric only"
  }
}

