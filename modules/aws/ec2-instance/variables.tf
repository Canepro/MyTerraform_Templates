variable "name" {
  description = "Name tag for the EC2 instance"
  type        = string

  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 255
    error_message = "Name must be between 1 and 255 characters"
  }
}

variable "project" {
  description = "Project tag applied to all resources"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]{1,64}$", var.project))
    error_message = "Project must be 1-64 characters using alphanumeric, hyphen, or underscore"
  }
}

variable "environment" {
  description = "Deployment environment (dev, training, prod)"
  type        = string
  default     = "training"

  validation {
    condition     = contains(["dev", "training", "prod"], var.environment)
    error_message = "Environment must be one of dev, training, or prod"
  }
}

variable "use_latest_ami" {
  description = "If true, automatically use the latest AMI for the selected os_distribution. If false, use ami_id."
  type        = bool
  default     = true
}

variable "ami_id" {
  description = "AMI ID to use for the instance (required if use_latest_ami is false)"
  type        = string
  default     = null

  validation {
    condition = var.use_latest_ami || (var.ami_id != null && can(regex("^ami-[a-z0-9]+$", var.ami_id)))
    error_message = "AMI ID must be in the format ami-xxxxxxxxx or set use_latest_ami to true"
  }
}

variable "os_distribution" {
  description = "Base operating system to deploy (amazon-linux or ubuntu)"
  type        = string
  default     = "amazon-linux"

  validation {
    condition     = contains(["amazon-linux", "ubuntu"], var.os_distribution)
    error_message = "os_distribution must be one of: amazon-linux, ubuntu"
  }
}

variable "instance_type" {
  description = "EC2 instance type. Defaults are derived from the environment profile when null."
  type        = string
  default     = null
}

variable "root_volume_size" {
  description = "Root volume size in GB. Defaults are derived from the environment profile when null."
  type        = number
  default     = null

  validation {
    condition     = var.root_volume_size == null || (var.root_volume_size >= 30 && var.root_volume_size <= 16384)
    error_message = "Root volume size must be between 30 and 16384 GB"
  }
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

variable "vpc_id" {
  description = "Optional VPC ID. Defaults to the AWS account's default VPC when null."
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Optional subnet ID. Defaults to a public subnet in the default VPC when null."
  type        = string
  default     = null
}

variable "availability_zone" {
  description = "Optional availability zone hint when selecting a default subnet."
  type        = string
  default     = null
}

variable "allowed_ports" {
  description = "List of TCP ports to allow inbound from allowed_cidrs."
  type        = list(number)
  default     = [22, 80, 8080]

  validation {
    condition     = length([for port in var.allowed_ports : port if port > 0 && port <= 65535]) == length(var.allowed_ports)
    error_message = "Allowed ports must be between 1 and 65535"
  }
}

variable "allowed_cidrs" {
  description = "CIDR blocks allowed to access the instance via the security group."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "additional_security_group_ids" {
  description = "Additional security group IDs to attach to the instance."
  type        = list(string)
  default     = []
}

variable "enable_eip" {
  description = "Attach an Elastic IP for static access."
  type        = bool
  default     = true
}

variable "key_name" {
  description = "Name of the SSH key pair (optional)"
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "IAM instance profile name to attach to the instance"
  type        = string
  default     = null
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring (additional cost)"
  type        = bool
  default     = false
}

variable "enable_auto_shutdown" {
  description = "Automatically schedule the instance to shut down after auto_shutdown_hours."
  type        = bool
  default     = true
}

variable "auto_shutdown_hours" {
  description = "Number of hours after launch before issuing a shutdown."
  type        = number
  default     = 4

  validation {
    condition     = var.auto_shutdown_hours >= 1 && var.auto_shutdown_hours <= 24
    error_message = "Auto shutdown hours must be between 1 and 24"
  }
}

variable "user_data" {
  description = "Additional user data script to run on instance launch."
  type        = string
  default     = null
}

variable "enable_termination_protection" {
  description = "Enable termination protection (recommended for production)"
  type        = bool
  default     = false
}

variable "install_docker" {
  description = "Install Docker on the VM"
  type        = bool
  default     = true
}

variable "install_jenkins" {
  description = "Install Jenkins on the VM (requires Docker if set to true)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags to merge with the mandatory baseline tags."
  type        = map(string)
  default     = {}
}
