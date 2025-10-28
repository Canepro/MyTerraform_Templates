variable "environment" {
  description = "Environment name (e.g., sandbox, dev, prod)"
  type        = string

  validation {
    condition     = contains(["sandbox", "dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: sandbox, dev, staging, prod"
  }
}

variable "managed_by" {
  description = "Tool or team managing the resource (e.g., terraform, devops-team)"
  type        = string
  default     = "terraform"
}

variable "cost_center" {
  description = "Cost center or department code for billing purposes"
  type        = string
  default     = "engineering"
}

variable "custom_tags" {
  description = "Additional custom tags to apply to resources"
  type        = map(string)
  default     = {}
}

