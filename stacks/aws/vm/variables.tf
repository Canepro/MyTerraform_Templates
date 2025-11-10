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
  description = "Environment profile (dev, training, prod)"
  type        = string
  default     = "training"

  validation {
    condition     = contains(["dev", "training", "prod"], var.environment)
    error_message = "Environment must be dev, training, or prod"
  }
}

variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "os_distribution" {
  description = "Operating system (amazon-linux or ubuntu)"
  type        = string
  default     = "amazon-linux"

  validation {
    condition     = contains(["amazon-linux", "ubuntu"], var.os_distribution)
    error_message = "os_distribution must be amazon-linux or ubuntu"
  }
}

variable "use_latest_ami" {
  description = "Automatically use the latest AMI for the selected OS"
  type        = bool
  default     = true
}

variable "ami_id" {
  description = "Specific AMI ID (only used if use_latest_ami is false)"
  type        = string
  default     = null
}

variable "instance_type" {
  description = "EC2 instance type (null uses environment default)"
  type        = string
  default     = null
}

variable "root_volume_size" {
  description = "Root volume size in GB (null uses environment default)"
  type        = number
  default     = null

  validation {
    condition     = var.root_volume_size == null || (var.root_volume_size >= 30 && var.root_volume_size <= 16384)
    error_message = "Root volume size must be between 30 and 16384 GB"
  }
}

variable "root_volume_type" {
  description = "Root volume type (gp3 recommended)"
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2", "st1", "sc1"], var.root_volume_type)
    error_message = "Must be a valid EBS volume type"
  }
}

variable "vpc_id" {
  description = "VPC ID (null uses default VPC)"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID (null uses default VPC subnet)"
  type        = string
  default     = null
}

variable "availability_zone" {
  description = "Availability zone hint for subnet selection"
  type        = string
  default     = null
}

variable "allowed_ports" {
  description = "TCP ports to allow inbound"
  type        = list(number)
  default     = [22, 80, 8080]

  validation {
    condition     = length([for port in var.allowed_ports : port if port > 0 && port <= 65535]) == length(var.allowed_ports)
    error_message = "Allowed ports must be between 1 and 65535"
  }
}

variable "allowed_cidrs" {
  description = "CIDR blocks allowed to access the instance"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "key_name" {
  description = "AWS key pair name for SSH access"
  type        = string
  default     = null
}

variable "enable_eip" {
  description = "Allocate and attach an Elastic IP"
  type        = bool
  default     = true
}

variable "enable_auto_shutdown" {
  description = "Enable 4-hour auto-shutdown helper"
  type        = bool
  default     = true
}

variable "auto_shutdown_hours" {
  description = "Hours before auto-shutdown triggers"
  type        = number
  default     = 4

  validation {
    condition     = var.auto_shutdown_hours > 0 && var.auto_shutdown_hours <= 24
    error_message = "Auto-shutdown hours must be between 1 and 24"
  }
}

variable "user_data" {
  description = "Additional user data script (appended after auto-shutdown helper)"
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type        = string
  default     = null
}

variable "enable_detailed_monitoring" {
  description = "Enable CloudWatch detailed monitoring"
  type        = bool
  default     = false
}

variable "enable_termination_protection" {
  description = "Enable termination protection"
  type        = bool
  default     = false
}

variable "install_docker" {
  description = "Install Docker on the VM"
  type        = bool
  default     = true
}

variable "install_jenkins" {
  description = "Install Jenkins on the VM"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
