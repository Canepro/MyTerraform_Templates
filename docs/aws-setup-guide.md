# AWS Account Setup and Deployment Guide

Complete guide to setting up AWS and deploying resources using MyTerraform_Templates.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [AWS Account Setup](#aws-account-setup)
3. [AWS CLI Installation](#aws-cli-installation)
4. [IAM User & Credentials](#iam-user--credentials)
5. [Terraform Configuration](#terraform-configuration)
6. [First Deployment](#first-deployment)
7. [Verification](#verification)
8. [Cost Management](#cost-management)
9. [Troubleshooting](#troubleshooting)

## Prerequisites

Before starting, ensure you have:

- **AWS Account**: Sign up at [aws.amazon.com](https://aws.amazon.com)
- **Credit Card**: Required for account verification (won't be charged within free tier)
- **Terraform** >= 1.5.0: [Install Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- **AWS CLI**: For authentication and management

### Verify Prerequisites

```bash
# Check Terraform version
terraform version
# Output: Terraform v1.5.0+

# Check AWS CLI
aws --version
# Output: aws-cli/2.x.x

# Verify git is installed
git --version
```

## AWS Account Setup

### Step 1: Create AWS Account

1. Go to [aws.amazon.com](https://aws.amazon.com)
2. Click **Sign In** → **Create a new AWS account**
3. Enter email, password, and account name
4. Choose **Personal** or **Professional**
5. Enter credit card information (required, won't be charged within free tier)
6. Complete phone verification
7. Select **Basic Support Plan** (Free)

### Step 2: Activate AWS Free Tier

After account creation:

1. Sign in to [AWS Console](https://console.aws.amazon.com)
2. Navigate to **Services** → **Billing & Cost Management**
3. Review [Free Tier Details](https://aws.amazon.com/free/)
4. Enable **Free Tier Usage Alerts**

**Free Tier includes** (for 12 months):
- ✅ 750 hours/month of EC2 t2.micro
- ✅ 5GB S3 storage
- ✅ 750 hours/month RDS db.t2.micro
- ✅ 1M Lambda requests/month
- ✅ 15GB data transfer out
- And more...

### Step 3: Set Up Budget Alerts

```bash
# After logging in with AWS CLI (see below)
aws budgets create-budget \
  --account-id $(aws sts get-caller-identity --query Account --output text) \
  --budget '{
    "BudgetName": "Free-Tier-Alert",
    "BudgetLimit": {"Amount": "1.00", "Unit": "USD"},
    "TimeUnit": "MONTHLY",
    "BudgetType": "COST"
  }' \
  --notifications-with-subscribers '[{
    "Notification": {
      "NotificationType": "ACTUAL",
      "ComparisonOperator": "GREATER_THAN",
      "Threshold": 80
    },
    "Subscribers": [{"SubscriptionType": "EMAIL", "Address": "your-email@example.com"}]
  }]'
```

## AWS CLI Installation

### Linux (WSL/Ubuntu)

```bash
# Download installer
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Install
unzip awscliv2.zip
sudo ./aws/install

# Verify
aws --version
```

### macOS

```bash
# Using Homebrew
brew install awscli

# Or download from AWS
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /

# Verify
aws --version
```

### Windows

```powershell
# Using MSI installer
# Download from: https://awscli.amazonaws.com/AWSCLIV2.msi

# Or using winget
winget install Amazon.AWSCLI

# Verify
aws --version
```

## IAM User & Credentials

**Never use root credentials** for Terraform. Create an IAM user instead.

### Step 1: Create IAM User

1. Sign in to [IAM Console](https://console.aws.amazon.com/iam)
2. Click **Users** → **Add users**
3. Username: `terraform-user` (or your choice)
4. Select **Provide user access to the AWS Management Console** (optional)
5. Click **Next**

### Step 2: Attach Permissions

For Terraform, attach the **PowerUserAccess** policy (for production, use least privilege):

1. Click **Attach policies directly**
2. Search for `PowerUserAccess`
3. Check the box
4. Click **Next** → **Create user**

**PowerUserAccess** includes:
- ✅ Full access to most AWS services
- ✅ Cannot modify IAM and users
- ✅ Safe for development/testing

**Production alternative**: Create custom policy with minimal required permissions.

### Step 3: Create Access Keys

1. Click on the created user
2. Go to **Security credentials** tab
3. Click **Create access key**
4. Choose **Command Line Interface (CLI)**
5. Click **Create access key**
6. **IMPORTANT**: Copy `Access Key ID` and `Secret Access Key`
7. Save securely (you won't see the secret key again!)

### Step 4: Configure AWS CLI

```bash
# Configure credentials
aws configure

# Enter when prompted:
# AWS Access Key ID: [Paste your access key]
# AWS Secret Access Key: [Paste your secret key]
# Default region name: us-east-1
# Default output format: json

# Verify configuration
aws sts get-caller-identity
# Should show your account and user details
```

### Step 5: Configure AWS Profile (Optional)

For multiple AWS accounts:

```bash
# Add profile
aws configure --profile myproject

# Use profile with Terraform
export AWS_PROFILE=myproject

# Verify
aws sts get-caller-identity --profile myproject
```

## Terraform Configuration

### Step 1: Clone Repository

```bash
git clone https://github.com/Canepro/MyTerraform_Templates.git
cd MyTerraform_Templates
```

### Step 2: Set Up AWS Provider

AWS modules use the official HashiCorp AWS provider:

```hcl
# In your stack main.tf
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
  region = "us-east-1"
  
  # Optional: Use AWS profile
  # profile = "myproject"
  
  # Optional: Specify default tags
  default_tags {
    tags = {
      Environment = "sandbox"
      ManagedBy   = "terraform"
    }
  }
}
```

### Step 3: Choose Region

**Recommended regions** (cost-effective):

| Region | Code | Location |
|--------|------|----------|
| US East (N. Virginia) | us-east-1 | Cheapest ✅ |
| US West (Oregon) | us-west-2 | ~5% more |
| Europe (Ireland) | eu-west-1 | ~10% more |
| Asia Pacific (Tokyo) | ap-northeast-1 | ~15% more |

**Set region**:
```bash
export AWS_DEFAULT_REGION=us-east-1
# Or in terraform.tfvars
# region = "us-east-1"
```

## First Deployment

Let's deploy the AWS sandbox stack (once created) or a simple S3 bucket.

### Example: Deploy S3 Bucket Stack

1. **Create stack directory**:
```bash
mkdir -p stacks/aws/sandbox
cd stacks/aws/sandbox
```

2. **Create main.tf**:
```hcl
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
  region = "us-east-1"
}

# Common naming
module "naming" {
  source = "../../../modules/common/naming"
  
  prefix      = var.prefix
  environment = var.environment
}

# S3 bucket
module "s3_bucket" {
  source = "../../../modules/aws/s3-bucket"
  
  bucket_name = "${var.prefix}-sandbox-${random_id.bucket_suffix.hex}"
  
  # Enable versioning
  versioning = {
    status = "Enabled"
  }
  
  # Security: encryption
  server_side_encryption_configuration = {
    sse_algorithm = "AES256"
  }
  
  tags = {
    environment = "sandbox"
    managed_by  = "terraform"
  }
}

# Random suffix for unique bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Outputs
output "bucket_name" {
  value = module.s3_bucket.bucket_name
}

output "bucket_arn" {
  value = module.s3_bucket.bucket_arn
}
```

3. **Create variables.tf**:
```hcl
variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "myapp"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "sandbox"
}
```

4. **Initialize and deploy**:
```bash
# Initialize
terraform init

# Review plan
terraform plan

# Apply
terraform apply

# Type 'yes' when prompted
```

## Verification

### Check Deployed Resources

```bash
# List S3 buckets
aws s3 ls

# List EC2 instances
aws ec2 describe-instances --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PrivateIP]'

# List VPCs
aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,CidrBlock,State]'

# Check IAM roles
aws iam list-roles --query 'Roles[*].[RoleName,CreateDate]'
```

### View CloudWatch Metrics

```bash
# View billing dashboard
aws budgets describe-budgets

# Check free tier usage
aws service-quotas get-service-quota \
  --service-code ec2 \
  --quota-code L-0263D0A3
```

### Terraform Outputs

```bash
# View all outputs
terraform output

# Specific output
terraform output bucket_name
```

## Cost Management

### Monitor Costs

1. **AWS Cost Explorer**:
   - Navigate to [Billing Dashboard](https://console.aws.amazon.com/billing)
   - Click **Cost Explorer**
   - View forecasts and trends

2. **AWS Budgets**:
```bash
# Create cost budget
aws budgets create-budget \
  --account-id $(aws sts get-caller-identity --query Account --output text) \
  --budget '{
    "BudgetName": "Sandbox-Budget",
    "BudgetLimit": {"Amount": "10.00", "Unit": "USD"},
    "TimeUnit": "MONTHLY",
    "BudgetType": "COST"
  }'
```

3. **Free Tier Alerts**:
   - Configure in Billing Dashboard
   - Get email when approaching free tier limits

### Cost Optimization Tips

1. **Use Free Tier Resources**:
   - t2.micro instances (750 hours/month)
   - S3 storage (5GB)
   - Lambda (1M requests/month)

2. **Stop When Not in Use**:
   ```bash
   # Stop EC2 instances when idle
   aws ec2 stop-instances --instance-ids i-1234567890abcdef0
   ```

3. **Use ARM-based Instances**:
   - t4g.nano is 20% cheaper than t2/t3
   - Requires ARM-compatible AMIs

4. **Enable Cost Allocation Tags**:
   ```bash
   aws ce update-cost-allocation-tags-status \
     --cost-allocation-tags-status-enable \
     Tags="Environment","ManagedBy"
   ```

### Calculate Costs

Use [AWS Pricing Calculator](https://calculator.aws) to estimate:
- EC2: $0.01/hour for t3.micro = ~$7.30/month
- S3: $0.023/GB/month for Standard storage
- Data Transfer: $0.09/GB after first 1GB

## Troubleshooting

### Issue: Access Denied

**Error**: `AccessDenied: User: arn:aws:iam::123456789012:user/terraform-user is not authorized to perform: s3:CreateBucket`

**Solution**: Add missing permissions
```bash
# Attach additional policy
aws iam attach-user-policy \
  --user-name terraform-user \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
```

### Issue: Region Mismatch

**Error**: `Could not find AMI with ID: ami-12345678`

**Solution**: AMIs are region-specific
```bash
# Find AMI in your region
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=al2023-ami-*" \
  --query 'Images[*].[ImageId,Name,CreationDate]' \
  --output table
```

### Issue: Credentials Not Found

**Error**: `NoCredentialsError: Unable to locate credentials`

**Solution**: Configure AWS CLI
```bash
aws configure
# Enter credentials

# Or set environment variables
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
```

### Issue: Budget Exceeded

**Solution**: Set up alerts and limits
```bash
# Create billing alarm
aws cloudwatch put-metric-alarm \
  --alarm-name billing-alert \
  --alarm-description "Alert when charges exceed $10" \
  --metric-name EstimatedCharges \
  --namespace AWS/Billing \
  --statistic Maximum \
  --period 86400 \
  --evaluation-periods 1 \
  --threshold 10 \
  --comparison-operator GreaterThanThreshold \
  --dimensions Name=Currency,Value=USD
```

### Issue: Rate Limiting

**Error**: `Rate exceeded` or `Throttling`

**Solution**: Terraform handles retries automatically, but you can:
```hcl
# In terraform.tfvars or backend config
terraform {
  backend "s3" {
    # Add retry logic
  }
}

# Or in provider config
provider "aws" {
  retry_mode = "adaptive"
  max_retries = 25
}
```

### Issue: Terraform State Lock

**Error**: `Error acquiring the state lock`

**Solution**: Force unlock (use carefully!)
```bash
# View lock info
terraform force-unlock -force LOCK_ID

# Or check who has the lock
aws dynamodb get-item \
  --table-name terraform-state-lock \
  --key '{"LockID":{"S":"STATE_LOCK_ID"}}'
```

## Next Steps

1. **Explore Modules**: Check out S3, VPC, EC2, and IAM modules
2. **Create Stacks**: Build dev/prod environments
3. **CI/CD**: Set up GitHub Actions for automated deployments
4. **State Management**: Configure S3 + DynamoDB for remote state
5. **Security**: Implement least privilege IAM policies

## Resources

### Official Documentation

- [AWS Documentation](https://docs.aws.amazon.com/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [AWS Free Tier](https://aws.amazon.com/free/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

### Tools

- [AWS CLI Reference](https://docs.aws.amazon.com/cli/latest/reference/)
- [AWS Pricing Calculator](https://calculator.aws)
- [AWS Architecture Center](https://aws.amazon.com/architecture/)

### Learning

- [AWS Training](https://aws.amazon.com/training/)
- [AWS Workshop Studio](https://workshops.aws/)
- [AWS Well-Architected Labs](https://www.wellarchitectedlabs.com/)

---

**Ready to deploy!** 🚀 See module READMEs in `modules/aws/` for specific resource deployment examples.

**Need help?** Open an issue or start a discussion in the repository.

