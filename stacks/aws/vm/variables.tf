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
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type (t3.micro is free tier eligible)"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of the AWS key pair to use for SSH access (REQUIRED)"
  type        = string
  default     = ""
}

variable "key_path" {
  description = "Path to the SSH private key (.pem file) for SSH access"
  type        = string
  default     = ""
}

variable "root_volume_type" {
  description = "Root volume type (gp3 is cheaper and faster than gp2)"
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2", "st1", "sc1"], var.root_volume_type)
    error_message = "Must be a valid EBS volume type"
  }
}

variable "root_volume_size" {
  description = "Root volume size in GB"
  type        = number
  default     = 30

  validation {
    condition     = var.root_volume_size >= 30 && var.root_volume_size <= 16384
    error_message = "Root volume size must be between 30 and 16384 GB"
  }
}

variable "enable_eip" {
  description = "Enable Elastic IP for static public IP"
  type        = bool
  default     = true
}
