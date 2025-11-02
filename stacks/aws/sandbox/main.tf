terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "terraform"
      CostCenter  = var.cost_center
    }
  }
}

# Random suffix for globally unique bucket names
resource "random_id" "suffix" {
  byte_length = 4
}

# Common naming convention
module "naming" {
  source = "../../../modules/common/naming"

  prefix      = var.prefix
  environment = var.environment
  suffix      = var.suffix
}

# Common tags
module "tags" {
  source = "../../../modules/common/tags"

  environment = var.environment
  managed_by  = "terraform"
  cost_center = var.cost_center
  custom_tags = var.custom_tags
}

# VPC with public and private subnets
module "vpc" {
  source = "../../../modules/aws/vpc"

  name               = module.naming.virtual_network
  cidr_block         = var.vpc_cidr
  availability_zones = var.availability_zones

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  tags = module.tags.tags
}

# S3 Bucket for storage
module "s3_bucket" {
  source = "../../../modules/aws/s3-bucket"

  bucket_name      = "${var.prefix}-${var.environment}-${random_id.suffix.hex}"
  enable_versioning = false  # Disable for sandbox to save costs

  tags = merge(
    module.tags.tags,
    {
      Purpose = "sandbox-storage"
    }
  )
}

# Security Group for EC2 instances (if creating any)
resource "aws_security_group" "default" {
  name_prefix = "${var.prefix}-${var.environment}-"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for ${var.environment} resources"

  # Allow SSH from anywhere (customize this in production!)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound"
  }

  tags = merge(
    module.tags.tags,
    {
      Name = "${var.prefix}-${var.environment}-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}
