variable "name" {
  description = "Name tag for the EC2 instance"
  type        = string

  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 255
    error_message = "Name must be between 1 and 255 characters"
  }
}

variable "use_latest_ami" {
  description = "If true, automatically use the latest Amazon Linux 2023 AMI (recommended). If false, use ami_id."
  type        = bool
  default     = false
}

variable "ami_id" {
  description = "AMI ID to use for the instance (required if use_latest_ami is false)"
  type        = string
  default     = ""

  validation {
    condition     = var.use_latest_ami || (can(regex("^ami-[a-z0-9]+$", var.ami_id)) && length(var.ami_id) > 0)
    error_message = "AMI ID must be in the format ami-xxxxxxxxx or set use_latest_ami to true"
  }
}

variable "instance_type" {
  description = "EC2 instance type (t3.micro for free tier, t4g.nano for ARM cheapest)"
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Subnet ID where the instance will be launched"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the instance"
  type        = list(string)
  default     = []
}

variable "key_name" {
  description = "Name of the SSH key pair (optional)"
  type        = string
  default     = null
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
  default     = 8

  validation {
    condition     = var.root_volume_size >= 8 && var.root_volume_size <= 16384
    error_message = "Root volume size must be between 8 and 16384 GB"
  }
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring (additional cost)"
  type        = bool
  default     = false
}

variable "user_data" {
  description = "User data script to run on instance launch"
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "IAM instance profile name to attach to the instance"
  type        = string
  default     = null
}

variable "enable_termination_protection" {
  description = "Enable termination protection (recommended for production)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the instance and volumes"
  type        = map(string)
  default     = {}
}
