# ============================================
# Provider Configuration - US West 2
# ============================================
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
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.project_name
      Region      = var.aws_region
    }
  }
}

# ============================================
# VPC Module
# ============================================
module "vpc" {
  source = "../../../modules/aws/vpc"
  
  name       = "${var.project_name}-${var.environment}-${var.aws_region}-vpc"
  cidr_block = var.vpc_cidr
  
  # Subnets
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  
  # NAT Gateway
  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
  
  # VPC Endpoints
  enable_s3_endpoint = var.enable_s3_endpoint
  
  # VPC Flow Logs
  enable_flow_logs            = var.enable_flow_logs
  flow_logs_retention_days    = var.flow_logs_retention_days
  flow_logs_traffic_type      = var.flow_logs_traffic_type
  
  # Tags
  tags = var.tags
}

