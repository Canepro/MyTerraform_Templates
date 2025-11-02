variable "prefix" {
  description = "Prefix for resource names (e.g., myapp, project name)"
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
  description = "Optional suffix for resource names (e.g., 001, east, west)"
  type        = string
  default     = ""
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"

  validation {
    condition = contains([
      "us-east-1", "us-east-2", "us-west-1", "us-west-2",
      "eu-west-1", "eu-central-1", "ap-southeast-1"
    ], var.region)
    error_message = "Must be a valid AWS region"
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
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (leave empty for sandbox)"
  type        = list(string)
  default     = []
}

