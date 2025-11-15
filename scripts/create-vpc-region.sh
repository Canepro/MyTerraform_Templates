#!/bin/bash
#
# Create VPC stack for a new AWS region
#
# Usage: ./create-vpc-region.sh <region> <cidr> [environment]
#
# Examples:
#   ./create-vpc-region.sh eu-west-1 10.2.0.0/16
#   ./create-vpc-region.sh ap-south-1 10.3.0.0/16 prod
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check arguments
if [ $# -lt 2 ]; then
    echo -e "${RED}Error: Missing required arguments${NC}"
    echo ""
    echo "Usage: $0 <region> <cidr> [environment]"
    echo ""
    echo "Examples:"
    echo "  $0 eu-west-1 10.2.0.0/16"
    echo "  $0 ap-south-1 10.3.0.0/16 prod"
    echo ""
    echo "Popular regions:"
    echo "  - us-east-1 (Virginia)"
    echo "  - us-west-2 (Oregon)"
    echo "  - eu-west-1 (Ireland)"
    echo "  - ap-south-1 (Mumbai)"
    echo "  - ap-southeast-1 (Singapore)"
    exit 1
fi

REGION=$1
VPC_CIDR=$2
ENVIRONMENT=${3:-dev}

echo -e "${BLUE}=================================${NC}"
echo -e "${BLUE}AWS VPC Region Creator${NC}"
echo -e "${BLUE}=================================${NC}"
echo ""
echo -e "Region:      ${GREEN}${REGION}${NC}"
echo -e "VPC CIDR:    ${GREEN}${VPC_CIDR}${NC}"
echo -e "Environment: ${GREEN}${ENVIRONMENT}${NC}"
echo ""

# Extract CIDR components for subnet calculation
IFS='/' read -r CIDR_BASE CIDR_MASK <<< "$VPC_CIDR"
IFS='.' read -r OCTET1 OCTET2 OCTET3 OCTET4 <<< "$CIDR_BASE"

# Calculate subnet CIDRs
PUBLIC_SUBNET_1="${OCTET1}.${OCTET2}.1.0/24"
PUBLIC_SUBNET_2="${OCTET1}.${OCTET2}.2.0/24"
PRIVATE_SUBNET_1="${OCTET1}.${OCTET2}.11.0/24"
PRIVATE_SUBNET_2="${OCTET1}.${OCTET2}.12.0/24"

# Get availability zones for the region
echo -e "${YELLOW}Checking availability zones in ${REGION}...${NC}"
AZS=$(aws ec2 describe-availability-zones \
    --region "$REGION" \
    --query 'AvailabilityZones[0:2].ZoneName' \
    --output text 2>/dev/null || echo "")

if [ -z "$AZS" ]; then
    echo -e "${RED}Warning: Could not fetch AZs. Using defaults.${NC}"
    AZ1="${REGION}a"
    AZ2="${REGION}b"
else
    read -r AZ1 AZ2 <<< "$AZS"
fi

echo -e "${GREEN}✓ Availability Zones: ${AZ1}, ${AZ2}${NC}"
echo ""

# Set target directory
TARGET_DIR="stacks/aws/vpc-${REGION}"

# Check if directory exists
if [ -d "$TARGET_DIR" ]; then
    echo -e "${YELLOW}Warning: Directory ${TARGET_DIR} already exists!${NC}"
    read -p "Overwrite? (yes/no): " -r
    echo
    if [[ ! $REPLY =~ ^[Yy]es$ ]]; then
        echo -e "${RED}Cancelled.${NC}"
        exit 1
    fi
fi

# Create directory
echo -e "${BLUE}Creating stack directory...${NC}"
mkdir -p "$TARGET_DIR"

# Create main.tf
echo -e "${BLUE}Creating main.tf...${NC}"
cat > "$TARGET_DIR/main.tf" << 'EOF'
# ============================================
# Provider Configuration
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
EOF

# Create variables.tf
echo -e "${BLUE}Creating variables.tf...${NC}"
cat > "$TARGET_DIR/variables.tf" << EOF
# ============================================
# General Configuration
# ============================================
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "${REGION}"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "${ENVIRONMENT}"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "my-project"
}

# ============================================
# VPC Configuration
# ============================================
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "${VPC_CIDR}"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["${AZ1}", "${AZ2}"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["${PUBLIC_SUBNET_1}", "${PUBLIC_SUBNET_2}"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["${PRIVATE_SUBNET_1}", "${PRIVATE_SUBNET_2}"]
}

# ============================================
# NAT Gateway Configuration
# ============================================
variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway (cost savings) vs one per AZ (high availability)"
  type        = bool
  default     = false
}

# ============================================
# VPC Endpoints
# ============================================
variable "enable_s3_endpoint" {
  description = "Enable S3 VPC endpoint (no data transfer charges)"
  type        = bool
  default     = true
}

# ============================================
# VPC Flow Logs
# ============================================
variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs for network monitoring"
  type        = bool
  default     = true
}

variable "flow_logs_retention_days" {
  description = "Number of days to retain flow logs"
  type        = number
  default     = 7
}

variable "flow_logs_traffic_type" {
  description = "Type of traffic to log (ACCEPT, REJECT, ALL)"
  type        = string
  default     = "ALL"
}

# ============================================
# Tags
# ============================================
variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
EOF

# Create outputs.tf
echo -e "${BLUE}Creating outputs.tf...${NC}"
cat > "$TARGET_DIR/outputs.tf" << 'EOF'
# ============================================
# VPC Outputs
# ============================================
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = module.vpc.vpc_arn
}

# ============================================
# Subnet Outputs
# ============================================
output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnet_ids
}

# ============================================
# NAT Gateway Outputs
# ============================================
output "nat_gateway_ids" {
  description = "IDs of NAT Gateways"
  value       = module.vpc.nat_gateway_ids
}

output "nat_gateway_public_ips" {
  description = "Public IPs of NAT Gateways"
  value       = module.vpc.nat_gateway_public_ips
}

# ============================================
# Route Table Outputs
# ============================================
output "public_route_table_id" {
  description = "ID of public route table"
  value       = module.vpc.public_route_table_id
}

output "private_route_table_ids" {
  description = "IDs of private route tables"
  value       = module.vpc.private_route_table_ids
}

# ============================================
# Quick Reference
# ============================================
output "deployment_info" {
  description = "Quick reference for your VPC deployment"
  value = {
    vpc_id              = module.vpc.vpc_id
    region              = var.aws_region
    environment         = var.environment
    public_subnets      = length(module.vpc.public_subnet_ids)
    private_subnets     = length(module.vpc.private_subnet_ids)
    nat_gateways        = length(module.vpc.nat_gateway_ids)
    flow_logs_enabled   = var.enable_flow_logs
    s3_endpoint_enabled = var.enable_s3_endpoint
  }
}
EOF

# Create terraform.tfvars.example
echo -e "${BLUE}Creating terraform.tfvars.example...${NC}"
cat > "$TARGET_DIR/terraform.tfvars.example" << EOF
# ============================================
# ${REGION} Region VPC Configuration
# ============================================
aws_region   = "${REGION}"
environment  = "${ENVIRONMENT}"
project_name = "my-project"

# VPC Configuration
vpc_cidr           = "${VPC_CIDR}"
availability_zones = ["${AZ1}", "${AZ2}"]

# Public Subnets
public_subnet_cidrs = [
  "${PUBLIC_SUBNET_1}",  # ${AZ1}
  "${PUBLIC_SUBNET_2}"   # ${AZ2}
]

# Private Subnets
private_subnet_cidrs = [
  "${PRIVATE_SUBNET_1}", # ${AZ1}
  "${PRIVATE_SUBNET_2}"  # ${AZ2}
]

# NAT Gateway
enable_nat_gateway = true
single_nat_gateway = true  # Set to false for HA

# VPC Endpoints
enable_s3_endpoint = true

# VPC Flow Logs
enable_flow_logs         = true
flow_logs_retention_days = 7
flow_logs_traffic_type   = "ALL"

# Additional Tags
tags = {
  Team        = "DevOps"
  CostCenter  = "Engineering"
  Application = "Infrastructure"
}
EOF

# Create README.md
echo -e "${BLUE}Creating README.md...${NC}"
cat > "$TARGET_DIR/README.md" << EOF
# AWS VPC - ${REGION} Region

VPC deployment for **${REGION}** region.

## 🚀 Quick Deploy

\`\`\`bash
# Navigate to this directory
cd ${TARGET_DIR}

# Copy example config
cp terraform.tfvars.example terraform.tfvars

# Customize if needed
nano terraform.tfvars

# Initialize and deploy
terraform init
terraform plan
terraform apply
\`\`\`

## 📋 Configuration

**Region:** ${REGION}  
**VPC CIDR:** ${VPC_CIDR}  
**Availability Zones:** ${AZ1}, ${AZ2}  
**Environment:** ${ENVIRONMENT}

### Subnets

- **Public:** ${PUBLIC_SUBNET_1}, ${PUBLIC_SUBNET_2}
- **Private:** ${PRIVATE_SUBNET_1}, ${PRIVATE_SUBNET_2}

## 💰 Cost Estimate

- **Development:** ~\$35-40/month (single NAT)
- **Production:** ~\$70-80/month (NAT per AZ)

## 📖 Full Documentation

See:
- VPC Module: \`modules/aws/vpc/README.md\`
- Multi-Region Guide: \`stacks/aws/MULTI_REGION_GUIDE.md\`

## 🗑️ Cleanup

\`\`\`bash
terraform destroy
\`\`\`
EOF

# Summary
echo ""
echo -e "${GREEN}=================================${NC}"
echo -e "${GREEN}✓ Success!${NC}"
echo -e "${GREEN}=================================${NC}"
echo ""
echo -e "VPC stack created in: ${BLUE}${TARGET_DIR}${NC}"
echo ""
echo -e "${YELLOW}Configuration:${NC}"
echo "  Region:         ${REGION}"
echo "  VPC CIDR:       ${VPC_CIDR}"
echo "  AZs:            ${AZ1}, ${AZ2}"
echo "  Public Subnets: ${PUBLIC_SUBNET_1}, ${PUBLIC_SUBNET_2}"
echo "  Private Subnets: ${PRIVATE_SUBNET_1}, ${PRIVATE_SUBNET_2}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. cd ${TARGET_DIR}"
echo "  2. cp terraform.tfvars.example terraform.tfvars"
echo "  3. nano terraform.tfvars  # Customize if needed"
echo "  4. terraform init"
echo "  5. terraform plan"
echo "  6. terraform apply"
echo ""
echo -e "${GREEN}Happy deploying! 🚀${NC}"
EOF

chmod +x "$TARGET_DIR/../../../scripts/create-vpc-region.sh"

echo -e "${GREEN}✓ Script created successfully!${NC}"

