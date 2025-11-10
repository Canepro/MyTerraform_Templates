terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "ec2_vm" {
  source = "../../../modules/aws/ec2-instance"

  name        = "${var.project_name}-vm"
  project     = var.project_name
  environment = var.environment

  # OS selection
  os_distribution = var.os_distribution
  use_latest_ami  = var.use_latest_ami
  ami_id          = var.ami_id

  # Instance sizing (uses environment defaults if null)
  instance_type    = var.instance_type
  root_volume_size = var.root_volume_size
  root_volume_type = var.root_volume_type

  # Networking (uses default VPC if null)
  vpc_id            = var.vpc_id
  subnet_id         = var.subnet_id
  availability_zone = var.availability_zone

  # Security
  allowed_ports = var.allowed_ports
  allowed_cidrs = var.allowed_cidrs

  # SSH access
  key_name = var.key_name

  # Static IP
  enable_eip = var.enable_eip

  # Auto-shutdown for sandbox safety
  enable_auto_shutdown = var.enable_auto_shutdown
  auto_shutdown_hours  = var.auto_shutdown_hours

  # Optional features
  user_data                     = var.user_data
  iam_instance_profile          = var.iam_instance_profile
  enable_detailed_monitoring    = var.enable_detailed_monitoring
  enable_termination_protection = var.enable_termination_protection

  # Software installation
  install_docker  = var.install_docker
  install_jenkins = var.install_jenkins

  tags = var.tags
}

