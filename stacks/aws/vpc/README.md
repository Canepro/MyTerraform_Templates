# AWS VPC Stack - Ready to Deploy

Production-ready AWS VPC with best practices: NAT Gateway, VPC Flow Logs, proper routing, and VPC endpoints.

## 🚀 Quick Start

### 1. Configure AWS Credentials

```bash
# Option 1: Environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"

# Option 2: AWS CLI profile
aws configure
```

### 2. Copy Example Configuration

```bash
# For Development
cp terraform.tfvars.example terraform.tfvars

# For Production
cp terraform.tfvars.prod terraform.tfvars
```

### 3. Customize Your VPC

Edit `terraform.tfvars`:

```hcl
aws_region   = "us-east-1"
environment  = "dev"
project_name = "my-app"

vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]

public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

enable_nat_gateway = true
single_nat_gateway = true  # false for HA
```

### 4. Deploy!

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Deploy VPC
terraform apply

# View outputs
terraform output
```

---

## 📋 What Gets Created

### ✅ Core Infrastructure
- **VPC** with DNS support enabled
- **Public Subnets** (internet-accessible)
- **Private Subnets** (isolated)
- **Internet Gateway** for public subnet access

### ✅ NAT Configuration
- **NAT Gateway(s)** for private subnet internet access
- **Elastic IP(s)** for NAT Gateway
- Option for single NAT (cost) or per-AZ NAT (HA)

### ✅ Routing
- **Public Route Table** with internet gateway route
- **Private Route Tables** with NAT gateway routes
- Proper subnet associations

### ✅ Security & Monitoring
- **VPC Flow Logs** to CloudWatch
- **IAM Roles** for flow logs
- Configurable log retention

### ✅ Cost Optimization
- **S3 VPC Endpoint** (gateway) - no data charges
- Optional single NAT gateway

---

## 💰 Cost Estimate

### Development (single NAT)
- VPC, Subnets, IGW: **FREE**
- NAT Gateway: **~$32/month** + data transfer
- VPC Flow Logs: **~$1-5/month** (7 days retention)
- **Total: ~$35-40/month**

### Production (multi-AZ NAT)
- VPC, Subnets, IGW: **FREE**
- NAT Gateways (2x): **~$65/month** + data transfer
- VPC Flow Logs: **~$5-10/month** (30 days retention)
- **Total: ~$70-80/month**

💡 **Cost Savings Tips:**
- Use `single_nat_gateway = true` for dev (~50% savings)
- Enable S3 endpoint to avoid data transfer charges
- Set shorter flow log retention for dev environments

---

## 🔧 Configuration Options

### Environment Types

**Development:**
```hcl
single_nat_gateway = true   # Single NAT for cost savings
enable_flow_logs   = true   # 7 days retention
```

**Production:**
```hcl
single_nat_gateway = false  # NAT per AZ for HA
enable_flow_logs   = true   # 30 days retention
```

### NAT Gateway Strategies

**Single NAT Gateway** (Cost Optimized):
- ✅ Lower cost (~$32/month)
- ⚠️ Single point of failure
- 👍 Good for: dev/staging

**NAT per AZ** (High Availability):
- ✅ No single point of failure
- ✅ Better performance
- ⚠️ Higher cost (~$32/month per NAT)
- 👍 Good for: production

### CIDR Planning

**Small Environment** (< 500 resources):
```hcl
vpc_cidr             = "10.0.0.0/16"    # 65,536 IPs
public_subnet_cidrs  = ["10.0.1.0/24"]  # 256 IPs each
private_subnet_cidrs = ["10.0.11.0/24"] # 256 IPs each
```

**Large Environment** (> 500 resources):
```hcl
vpc_cidr             = "10.0.0.0/16"    # 65,536 IPs
public_subnet_cidrs  = ["10.0.1.0/26"]  # 64 IPs each (smaller)
private_subnet_cidrs = ["10.0.10.0/23"] # 512 IPs each (larger)
```

---

## 📊 After Deployment

### View Your VPC Details

```bash
# Show all outputs
terraform output

# Show specific output
terraform output vpc_id
terraform output nat_gateway_public_ips

# Quick deployment summary
terraform output deployment_info
```

### Connect Resources to Your VPC

Use the VPC outputs in other Terraform configurations:

```hcl
# In another stack (e.g., EC2 instances)
data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "../vpc/terraform.tfstate"
  }
}

resource "aws_instance" "app" {
  subnet_id = data.terraform_remote_state.vpc.outputs.private_subnet_ids[0]
  # ...
}
```

---

## 🎯 Common Use Cases

### Web Application (Public + Private Tier)
- **Public Subnets**: Load balancers, bastion hosts
- **Private Subnets**: Application servers, databases
- **NAT Gateway**: Private instances access internet for updates

### Microservices
- **Public Subnets**: API Gateway, ALB
- **Private Subnets**: ECS/EKS clusters, RDS
- **S3 Endpoint**: Reduce costs for S3 access

### Data Processing
- **Private Subnets**: EMR, Glue, batch processing
- **NAT Gateway**: Access external APIs
- **S3 Endpoint**: Read/write data without charges

---

## 🔒 Security Best Practices

This stack follows AWS best practices:

✅ Private subnets for backend resources
✅ NAT Gateway instead of NAT instances
✅ VPC Flow Logs enabled by default
✅ DNS hostnames enabled for service discovery
✅ S3 endpoint to avoid internet routing
✅ Separate route tables per subnet

---

## 🛠️ Troubleshooting

### "Error creating NAT Gateway: InsufficientFreeAddressesInSubnet"
**Solution**: Your public subnet CIDR is too small. Use at least /26 (64 IPs).

### "Private instances can't reach internet"
**Check**:
1. `enable_nat_gateway = true`
2. Private instances are in private subnets
3. Route tables properly associated

### "High data transfer costs"
**Solution**: 
1. Enable S3 endpoint: `enable_s3_endpoint = true`
2. Use VPC endpoints for other AWS services
3. Consider CloudFront for static content

---

## 🗑️ Cleanup

```bash
# Remove all resources
terraform destroy

# Review what will be deleted first
terraform plan -destroy
```

**Note**: NAT Gateways take ~5 minutes to delete.

---

## 📚 Next Steps

After your VPC is deployed:

1. **Deploy an EC2 Instance**: Use `../vm` stack
2. **Add an RDS Database**: See `../../modules/aws/rds-instance`
3. **Set up Load Balancer**: Configure ALB in public subnets
4. **Enable VPC Peering**: Connect to other VPCs
5. **Add Security Groups**: Fine-grained security rules

---

## 🆘 Need Help?

- **AWS VPC Documentation**: https://docs.aws.amazon.com/vpc/
- **Terraform AWS Provider**: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
- **View Module Code**: `../../../modules/aws/vpc/`

---

## 📝 Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         VPC (10.0.0.0/16)                    │
│                                                              │
│  ┌────────────────────────┐  ┌────────────────────────┐    │
│  │  Availability Zone A   │  │  Availability Zone B   │    │
│  │                        │  │                        │    │
│  │  ┌──────────────────┐ │  │ ┌──────────────────┐  │    │
│  │  │ Public Subnet    │ │  │ │ Public Subnet    │  │    │
│  │  │ 10.0.1.0/24      │ │  │ │ 10.0.2.0/24      │  │    │
│  │  │                  │ │  │ │                  │  │    │
│  │  │  [NAT Gateway]   │ │  │ │  [NAT Gateway]   │  │    │
│  │  └────────┬─────────┘ │  │ └────────┬─────────┘  │    │
│  │           │            │  │          │            │    │
│  │           │            │  │          │            │    │
│  │  ┌────────▼─────────┐ │  │ ┌────────▼─────────┐  │    │
│  │  │ Private Subnet   │ │  │ │ Private Subnet   │  │    │
│  │  │ 10.0.11.0/24     │ │  │ │ 10.0.12.0/24     │  │    │
│  │  │                  │ │  │ │                  │  │    │
│  │  │  [EC2/RDS/ECS]   │ │  │ │  [EC2/RDS/ECS]   │  │    │
│  │  └──────────────────┘ │  │ └──────────────────┘  │    │
│  └────────────────────────┘  └────────────────────────┘    │
│                                                              │
│  Internet Gateway                                           │
│         │                                                    │
└─────────┼────────────────────────────────────────────────────┘
          │
    ┌─────▼──────┐
    │  Internet  │
    └────────────┘
```

