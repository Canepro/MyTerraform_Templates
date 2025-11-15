# Quick VPC Deployment - Any Region

Three easy ways to deploy VPCs in different AWS regions.

---

## 🚀 Method 1: Use Pre-configured Stack (Fastest)

### US East 1 (Virginia) - Already configured!

```bash
cd stacks/aws/vpc
cp terraform.tfvars.example terraform.tfvars
terraform init && terraform apply
```

### US West 2 (Oregon) - Already configured!

```bash
cd stacks/aws/vpc-us-west-2
cp terraform.tfvars.example terraform.tfvars
terraform init && terraform apply
```

---

## 🛠️ Method 2: Use the Helper Script (Easiest)

Create a VPC in **any** region automatically:

```bash
# Navigate to project root
cd MyTerraform_Templates

# Create VPC for Europe (Ireland)
./scripts/create-vpc-region.sh eu-west-1 10.2.0.0/16

# Create VPC for Asia (Singapore)
./scripts/create-vpc-region.sh ap-southeast-1 10.3.0.0/16 prod

# Deploy it
cd stacks/aws/vpc-eu-west-1
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
```

**Script automatically:**
- ✅ Creates all necessary files
- ✅ Fetches availability zones
- ✅ Calculates subnet CIDRs
- ✅ Sets up proper configuration
- ✅ Creates documentation

---

## 📋 Method 3: Manual Setup (Most Control)

### Step 1: Copy existing stack

```bash
cd stacks/aws
cp -r vpc-us-west-2 vpc-eu-west-1
cd vpc-eu-west-1
```

### Step 2: Update variables.tf

```hcl
variable "aws_region" {
  default = "eu-west-1"  # Change region
}

variable "vpc_cidr" {
  default = "10.2.0.0/16"  # Different CIDR
}

variable "availability_zones" {
  default = ["eu-west-1a", "eu-west-1b"]  # Region AZs
}

variable "public_subnet_cidrs" {
  default = ["10.2.1.0/24", "10.2.2.0/24"]
}

variable "private_subnet_cidrs" {
  default = ["10.2.11.0/24", "10.2.12.0/24"]
}
```

### Step 3: Deploy

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
```

---

## 🌍 Popular Regions & CIDR Planning

| Region | Location | CIDR | AZs |
|--------|----------|------|-----|
| `us-east-1` | Virginia | `10.0.0.0/16` | us-east-1a, us-east-1b |
| `us-west-2` | Oregon | `10.1.0.0/16` | us-west-2a, us-west-2b |
| `eu-west-1` | Ireland | `10.2.0.0/16` | eu-west-1a, eu-west-1b |
| `eu-central-1` | Frankfurt | `10.3.0.0/16` | eu-central-1a, eu-central-1b |
| `ap-south-1` | Mumbai | `10.4.0.0/16` | ap-south-1a, ap-south-1b |
| `ap-southeast-1` | Singapore | `10.5.0.0/16` | ap-southeast-1a, ap-southeast-1b |
| `ap-northeast-1` | Tokyo | `10.6.0.0/16` | ap-northeast-1a, ap-northeast-1c |
| `sa-east-1` | São Paulo | `10.7.0.0/16` | sa-east-1a, sa-east-1c |

**💡 Tip:** Use different CIDR blocks to enable VPC peering between regions!

---

## 🎯 Quick Examples

### Deploy to Europe

```bash
# Option 1: Use script
./scripts/create-vpc-region.sh eu-west-1 10.2.0.0/16
cd stacks/aws/vpc-eu-west-1
cp terraform.tfvars.example terraform.tfvars
terraform init && terraform apply

# Option 2: Use existing directory structure
cd stacks/aws/vpc
terraform apply -var="aws_region=eu-west-1" -var="vpc_cidr=10.2.0.0/16"
```

### Deploy to Asia

```bash
# Singapore
./scripts/create-vpc-region.sh ap-southeast-1 10.3.0.0/16

# Tokyo
./scripts/create-vpc-region.sh ap-northeast-1 10.4.0.0/16

# Mumbai
./scripts/create-vpc-region.sh ap-south-1 10.5.0.0/16
```

### Deploy for Disaster Recovery

```bash
# Primary in us-east-1 (already exists)
cd stacks/aws/vpc
terraform apply

# DR in us-west-2 (already exists)
cd stacks/aws/vpc-us-west-2
terraform apply

# Set up VPC peering between them
# See: stacks/aws/MULTI_REGION_GUIDE.md
```

---

## 🔍 Check Your Deployments

### List all VPCs

```bash
# Per region
cd stacks/aws/vpc && terraform output vpc_id
cd stacks/aws/vpc-us-west-2 && terraform output vpc_id

# All regions with AWS CLI
aws ec2 describe-vpcs --region us-east-1 --query 'Vpcs[*].[VpcId,CidrBlock]'
aws ec2 describe-vpcs --region us-west-2 --query 'Vpcs[*].[VpcId,CidrBlock]'
aws ec2 describe-vpcs --region eu-west-1 --query 'Vpcs[*].[VpcId,CidrBlock]'
```

### Multi-region check script

```bash
#!/bin/bash
for region in us-east-1 us-west-2 eu-west-1; do
    echo "=== $region ==="
    aws ec2 describe-vpcs --region $region \
        --filters "Name=tag:ManagedBy,Values=Terraform" \
        --query 'Vpcs[*].[VpcId,CidrBlock,Tags[?Key==`Name`].Value|[0]]' \
        --output table
done
```

---

## 💰 Cost Per Region

Each VPC costs approximately:

| Configuration | NAT Gateway | Flow Logs | Total/month |
|--------------|-------------|-----------|-------------|
| **Dev** (single NAT) | $32 | $1-5 | **~$35-40** |
| **Prod** (HA NAT) | $65 | $5-10 | **~$70-80** |

**Multiple Regions:**
- 2 regions × $40 = **$80/month** (dev)
- 3 regions × $40 = **$120/month** (dev)
- 2 regions × $75 = **$150/month** (prod)
- 3 regions × $75 = **$225/month** (prod)

---

## ⚡ Common Commands

```bash
# Create new region VPC
./scripts/create-vpc-region.sh <region> <cidr>

# Initialize
terraform init

# Preview
terraform plan

# Deploy
terraform apply

# View details
terraform output
terraform output deployment_info

# Destroy
terraform destroy
```

---

## 📖 More Information

- **Module Documentation:** `modules/aws/vpc/README.md`
- **Multi-Region Guide:** `stacks/aws/MULTI_REGION_GUIDE.md`
- **Stack README:** `stacks/aws/vpc/README.md`

---

## 🆘 Quick Help

**Q: What CIDR should I use?**
A: Use the table above. Different CIDR per region allows peering.

**Q: How do I choose a region?**
A: Choose closest to your users for lowest latency.

**Q: Can I connect VPCs across regions?**
A: Yes! Use VPC peering. See `MULTI_REGION_GUIDE.md`.

**Q: How do I save costs?**
A: Use `single_nat_gateway = true` for non-prod environments.

---

Happy deploying! 🌍🚀

