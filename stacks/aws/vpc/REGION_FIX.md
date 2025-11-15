# Deploying VPC to Different Region - Common Issue Fix

## ❌ The Problem

When you deploy to a different region using `-var="aws_region=us-west-2"`, you **MUST** also change the availability zones!

Each region has different AZs:
- **us-east-1**: us-east-1a, us-east-1b, us-east-1c, etc.
- **us-west-2**: us-west-2a, us-west-2b, us-west-2c, us-west-2d

## ✅ Solutions

### Solution 1: Use Dedicated Directory (BEST)

Use the pre-configured `vpc-us-west-2` directory:

```bash
cd stacks/aws/vpc-us-west-2
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
```

This directory already has:
- ✅ Correct region: `us-west-2`
- ✅ Correct AZs: `["us-west-2a", "us-west-2b"]`
- ✅ Correct CIDR: `10.1.0.0/16`

### Solution 2: Pass All Variables

If using the `vpc` directory for different regions, pass ALL region-specific variables:

```bash
cd stacks/aws/vpc

terraform apply \
  -var="aws_region=us-west-2" \
  -var="vpc_cidr=10.1.0.0/16" \
  -var='availability_zones=["us-west-2a","us-west-2b"]' \
  -var='public_subnet_cidrs=["10.1.1.0/24","10.1.2.0/24"]' \
  -var='private_subnet_cidrs=["10.1.11.0/24","10.1.12.0/24"]'
```

### Solution 3: Use Helper Script

Create a new region-specific directory automatically:

```bash
# From project root
./scripts/create-vpc-region.sh us-west-2 10.1.0.0/16

# Deploy
cd stacks/aws/vpc-us-west-2
terraform init
terraform apply
```

## 🧹 Cleanup Partial Deployment

If you have partial resources from failed deployment:

```bash
# Manual cleanup via AWS Console
1. Go to VPC Console in us-west-2 region
2. Delete:
   - VPC Endpoints
   - NAT Gateways (wait ~5 min)
   - Elastic IPs
   - Flow Logs
   - Route Tables (custom ones)
   - Subnets
   - Internet Gateway
   - VPC

# Or use AWS CLI
aws ec2 describe-vpcs --region us-west-2 \
  --filters "Name=tag:ManagedBy,Values=Terraform" \
  --query 'Vpcs[*].VpcId' --output text

# Then delete VPC manually (if found)
# VPC ID from your error: vpc-0fec0f3ce389a37c8
```

## 📋 Region-AZ Quick Reference

| Region | Available AZs |
|--------|--------------|
| us-east-1 | us-east-1a, us-east-1b, us-east-1c, us-east-1d, us-east-1e, us-east-1f |
| us-east-2 | us-east-2a, us-east-2b, us-east-2c |
| us-west-1 | us-west-1a, us-west-1b, us-west-1c |
| us-west-2 | us-west-2a, us-west-2b, us-west-2c, us-west-2d |
| eu-west-1 | eu-west-1a, eu-west-1b, eu-west-1c |
| eu-central-1 | eu-central-1a, eu-central-1b, eu-central-1c |
| ap-southeast-1 | ap-southeast-1a, ap-southeast-1b, ap-southeast-1c |
| ap-northeast-1 | ap-northeast-1a, ap-northeast-1c, ap-northeast-1d |

## 🎯 Best Practice

**Always use separate directories for different regions:**

```
stacks/aws/
├── vpc/              # us-east-1 (default)
├── vpc-us-west-2/    # Oregon
├── vpc-eu-west-1/    # Ireland
└── vpc-ap-south-1/   # Mumbai
```

Benefits:
- ✅ No confusion about which region
- ✅ Correct AZs pre-configured
- ✅ Separate state files
- ✅ Easy to manage
- ✅ No variable conflicts

