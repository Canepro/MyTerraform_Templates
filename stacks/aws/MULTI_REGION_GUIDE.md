# Multi-Region VPC Deployment Guide

Deploy VPCs across multiple AWS regions easily.

## 🌍 Available Regions

Your VPC module works in **any** AWS region. Here are the most common:

### North America
- **us-east-1** (Virginia) - Default
- **us-east-2** (Ohio)
- **us-west-1** (N. California)
- **us-west-2** (Oregon) - Example provided
- **ca-central-1** (Canada)

### Europe
- **eu-west-1** (Ireland)
- **eu-west-2** (London)
- **eu-west-3** (Paris)
- **eu-central-1** (Frankfurt)
- **eu-north-1** (Stockholm)

### Asia Pacific
- **ap-south-1** (Mumbai)
- **ap-southeast-1** (Singapore)
- **ap-southeast-2** (Sydney)
- **ap-northeast-1** (Tokyo)
- **ap-northeast-2** (Seoul)

### South America
- **sa-east-1** (São Paulo)

---

## 🚀 Three Ways to Deploy Multiple Regions

### Option 1: Separate Directories (Recommended) ✅

**Best for:** Production, clear separation, easy management

```bash
stacks/aws/
├── vpc/              # us-east-1
├── vpc-us-west-2/    # us-west-2
├── vpc-eu-west-1/    # eu-west-1
└── vpc-ap-south-1/   # ap-south-1
```

**Pros:**
- ✅ Clear separation per region
- ✅ Independent state files
- ✅ Easy to manage
- ✅ No confusion

**Deploy:**
```bash
cd stacks/aws/vpc-us-west-2
terraform init
terraform apply
```

---

### Option 2: Same Directory with Variables

**Best for:** Quick deployments, temporary environments

```bash
cd stacks/aws/vpc

# Deploy to us-east-1
terraform apply -var="aws_region=us-east-1" -var="vpc_cidr=10.0.0.0/16"

# Deploy to us-west-2 (different state)
terraform apply -var="aws_region=us-west-2" -var="vpc_cidr=10.1.0.0/16"
```

**⚠️ Warning:** This creates resources in the same state file!

---

### Option 3: Terraform Workspaces

**Best for:** Same configuration, multiple environments/regions

```bash
cd stacks/aws/vpc

# Create workspaces per region
terraform workspace new us-east-1
terraform workspace new us-west-2
terraform workspace new eu-west-1

# Deploy to us-west-2
terraform workspace select us-west-2
terraform apply -var="aws_region=us-west-2" -var="vpc_cidr=10.1.0.0/16"

# Deploy to eu-west-1
terraform workspace select eu-west-1
terraform apply -var="aws_region=eu-west-1" -var="vpc_cidr=10.2.0.0/16"
```

---

## 📋 CIDR Planning for Multiple Regions

**Important:** Use different CIDR blocks for each region to enable VPC peering!

### Recommended CIDR Allocation

```hcl
# us-east-1
vpc_cidr = "10.0.0.0/16"

# us-west-2
vpc_cidr = "10.1.0.0/16"

# eu-west-1
vpc_cidr = "10.2.0.0/16"

# ap-south-1
vpc_cidr = "10.3.0.0/16"

# ap-southeast-1
vpc_cidr = "10.4.0.0/16"
```

### Alternative (RFC 1918 ranges)

```hcl
# us-east-1
vpc_cidr = "10.0.0.0/16"

# us-west-2
vpc_cidr = "172.16.0.0/16"

# eu-west-1
vpc_cidr = "192.168.0.0/16"
```

---

## 🎯 Quick Setup for New Region

### 1. Copy Existing Stack

```bash
# From stacks/aws/
cp -r vpc-us-west-2 vpc-eu-west-1
```

### 2. Update Configuration

Edit `vpc-eu-west-1/variables.tf`:

```hcl
variable "aws_region" {
  default = "eu-west-1"  # Change region
}

variable "vpc_cidr" {
  default = "10.2.0.0/16"  # Change CIDR
}

variable "availability_zones" {
  default = ["eu-west-1a", "eu-west-1b"]  # Change AZs
}

variable "public_subnet_cidrs" {
  default = ["10.2.1.0/24", "10.2.2.0/24"]  # Match CIDR
}

variable "private_subnet_cidrs" {
  default = ["10.2.11.0/24", "10.2.12.0/24"]  # Match CIDR
}
```

### 3. Deploy

```bash
cd vpc-eu-west-1
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
```

---

## 🔗 VPC Peering Between Regions

Connect your VPCs across regions:

### Create Peering Connection

```hcl
# In a separate peering configuration
resource "aws_vpc_peering_connection" "east_to_west" {
  provider = aws.us-east-1
  
  vpc_id      = "vpc-xxxxx"  # us-east-1 VPC
  peer_vpc_id = "vpc-yyyyy"  # us-west-2 VPC
  peer_region = "us-west-2"
  
  tags = {
    Name = "us-east-1-to-us-west-2"
  }
}

# Accept in peer region
resource "aws_vpc_peering_connection_accepter" "west" {
  provider                  = aws.us-west-2
  vpc_peering_connection_id = aws_vpc_peering_connection.east_to_west.id
  auto_accept               = true
}

# Add routes
resource "aws_route" "east_to_west" {
  provider                  = aws.us-east-1
  route_table_id            = "rtb-xxxxx"
  destination_cidr_block    = "10.1.0.0/16"  # us-west-2
  vpc_peering_connection_id = aws_vpc_peering_connection.east_to_west.id
}

resource "aws_route" "west_to_east" {
  provider                  = aws.us-west-2
  route_table_id            = "rtb-yyyyy"
  destination_cidr_block    = "10.0.0.0/16"  # us-east-1
  vpc_peering_connection_id = aws_vpc_peering_connection.east_to_west.id
}
```

---

## 📊 Multi-Region Architecture Patterns

### 1. Active-Active (Load Distributed)

```
┌─────────────┐         ┌─────────────┐
│  us-east-1  │ ◄─────► │  us-west-2  │
│  VPC        │ Peering │  VPC        │
│  10.0.0/16  │         │  10.1.0/16  │
└─────────────┘         └─────────────┘
     50% traffic            50% traffic
```

**Use case:** Global applications, disaster recovery

### 2. Primary-Secondary (DR)

```
┌─────────────┐         ┌─────────────┐
│  us-east-1  │ ──────► │  us-west-2  │
│  PRIMARY    │  Sync   │  STANDBY    │
│  10.0.0/16  │         │  10.1.0/16  │
└─────────────┘         └─────────────┘
   100% traffic           0% (failover)
```

**Use case:** Disaster recovery, compliance

### 3. Regional Isolation

```
┌─────────────┐         ┌─────────────┐
│  us-east-1  │    X    │  eu-west-1  │
│  US Users   │  No     │  EU Users   │
│  10.0.0/16  │ Peering │  10.2.0/16  │
└─────────────┘         └─────────────┘
```

**Use case:** Data sovereignty, GDPR compliance

---

## 💰 Cost Considerations

### Per Region Costs
- NAT Gateway: ~$32/month (single) or ~$64/month (HA)
- Flow Logs: ~$1-10/month
- **Total per region:** ~$35-75/month

### Multi-Region Costs
- **2 regions:** ~$70-150/month
- **3 regions:** ~$105-225/month
- **5 regions:** ~$175-375/month

### Data Transfer (VPC Peering)
- **Inter-region data transfer:** $0.02/GB
- Example: 100GB/month = $2/month

---

## 🛠️ Management Tips

### Use Consistent Naming

```hcl
# us-east-1
name = "myapp-prod-us-east-1-vpc"

# us-west-2
name = "myapp-prod-us-west-2-vpc"

# eu-west-1
name = "myapp-prod-eu-west-1-vpc"
```

### Use Tags for Organization

```hcl
tags = {
  Environment = "prod"
  Region      = "us-west-2"
  Primary     = "false"  # or "true" for primary region
  DR          = "true"   # disaster recovery region
}
```

### Track Resources by Region

```bash
# List all VPCs across regions
for region in us-east-1 us-west-2 eu-west-1; do
  echo "=== $region ==="
  aws ec2 describe-vpcs --region $region \
    --query 'Vpcs[*].[VpcId,CidrBlock,Tags[?Key==`Name`].Value|[0]]' \
    --output table
done
```

---

## 🔍 Verification

### Check VPCs Across Regions

```bash
# Show VPC in us-east-1
cd stacks/aws/vpc
terraform output vpc_id

# Show VPC in us-west-2
cd stacks/aws/vpc-us-west-2
terraform output vpc_id
```

### AWS CLI Multi-Region Check

```bash
#!/bin/bash
REGIONS=("us-east-1" "us-west-2" "eu-west-1")

for region in "${REGIONS[@]}"; do
    echo "=== $region ==="
    aws ec2 describe-vpcs \
        --region $region \
        --filters "Name=tag:ManagedBy,Values=Terraform" \
        --query 'Vpcs[*].[VpcId,CidrBlock]' \
        --output table
    echo ""
done
```

---

## 🗑️ Cleanup Multi-Region VPCs

```bash
# Destroy each region separately
cd stacks/aws/vpc
terraform destroy

cd stacks/aws/vpc-us-west-2
terraform destroy

cd stacks/aws/vpc-eu-west-1
terraform destroy
```

**⚠️ Important:** Destroy VPC peering connections first!

---

## 📚 Region-Specific Notes

### Availability Zones
Each region has different AZs. Check available AZs:

```bash
aws ec2 describe-availability-zones --region us-west-2
```

### Service Availability
Not all services are in all regions. Check before deploying:
- https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/

### Latency
Choose regions close to your users:
- **US East Coast users:** us-east-1
- **US West Coast users:** us-west-2
- **European users:** eu-west-1, eu-central-1
- **Asian users:** ap-southeast-1, ap-northeast-1

---

## ✅ Best Practices

1. **Different CIDR blocks** per region (enable peering)
2. **Consistent naming** convention
3. **Tag everything** with region identifier
4. **Separate state files** per region
5. **Document** which region is primary
6. **Monitor costs** across all regions
7. **Test failover** between regions regularly

---

## 🆘 Common Issues

### Issue: CIDR Overlap

**Problem:** Can't peer VPCs with same CIDR

**Solution:** Plan CIDRs before deployment
```hcl
us-east-1:  10.0.0.0/16
us-west-2:  10.1.0.0/16
eu-west-1:  10.2.0.0/16
```

### Issue: Wrong Availability Zones

**Problem:** `InvalidParameterValue: Invalid availability zone`

**Solution:** Check region's AZs first
```bash
aws ec2 describe-availability-zones --region us-west-2
```

### Issue: High Data Transfer Costs

**Problem:** Expensive inter-region traffic

**Solutions:**
- Enable VPC endpoints in each region
- Use CloudFront for static content
- Minimize cross-region traffic
- Consider regional data replication

---

## 🎓 Next Steps

1. **Deploy your second region**
   ```bash
   cd stacks/aws/vpc-us-west-2
   terraform apply
   ```

2. **Set up VPC peering** (if needed)

3. **Deploy application resources** in each VPC

4. **Configure Route53** for multi-region routing

5. **Test failover** between regions

---

Happy multi-region deploying! 🌍

