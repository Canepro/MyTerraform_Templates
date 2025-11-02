# AWS Sandbox Stack

A complete Terraform stack demonstrating AWS modules in a safe, cost-conscious sandbox environment.

## 🎯 Perfect for Beginners!

This is your **first AWS deployment** - a safe, free way to learn Terraform and AWS infrastructure!

**What you'll learn:**
- ✅ How to deploy AWS infrastructure with code
- ✅ How to use Terraform modules (VPC, S3)
- ✅ How to manage cloud resources safely
- ✅ How to clean up when done

**Don't worry!** This guide assumes no prior knowledge. If you get stuck, check the [Getting Started Guide](../../../docs/GETTING_STARTED.md).

## Overview

This stack creates:
- ✅ **Virtual Private Cloud (VPC)** with subnets (Always Free)
- ✅ **Internet Gateway** for VPC (Always Free)
- ✅ **S3 Bucket** with encryption (Free tier: 5GB)
- ✅ **Security Group** for future EC2 instances (Always Free)

**Estimated Cost**: $0.00/month (within free tier limits)

**Time to Deploy**: ~3 minutes  
**Difficulty**: ⭐ Easy

## Architecture

```
VPC (10.0.0.0/16)
├── Internet Gateway
├── Public Subnet 1 (10.0.1.0/24) in us-east-1a
├── Public Subnet 2 (10.0.2.0/24) in us-east-1b
├── Security Group (SSH access)
└── S3 Bucket (encrypted, versioned)
```

## Prerequisites

**Don't have these installed?** Follow the [AWS Setup Guide](../../../docs/aws-setup-guide.md) or [Getting Started Guide](../../../docs/GETTING_STARTED.md#aws-beginner-guide) for step-by-step installation instructions.

### Required Tools

1. **AWS CLI** installed and configured:
   ```bash
   aws --version
   # Should show: aws-cli/2.x.x
   
   aws configure
   # Enter your Access Key ID, Secret Access Key, and region
   ```
   **Need to install?** See [AWS CLI Installation Guide](https://aws.amazon.com/cli/)

2. **Terraform** >= 1.5.0:
   ```bash
   terraform version
   ```
   **Need to install?** See [Terraform Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)

3. **AWS Account** with appropriate permissions:
   - IAM permissions to create VPC, S3, Security Groups
   - **Don't have one?** Sign up for free at [aws.amazon.com](https://aws.amazon.com)

## Quick Start

**Follow these steps in order!** Each step builds on the previous one.

### Step 1: Clone the Repository

First, get the code onto your computer:

```bash
# Clone the repository
git clone https://github.com/Canepro/MyTerraform_Templates.git

# Navigate into the project
cd MyTerraform_Templates/stacks/aws/sandbox
```

### Step 2: Configure AWS Credentials

If you haven't already configured AWS CLI:

```bash
# Configure your credentials
aws configure

# You'll need:
# AWS Access Key ID: [Your access key]
# AWS Secret Access Key: [Your secret key]
# Default region name: us-east-1
# Default output format: json

# Verify configuration
aws sts get-caller-identity
```

### Step 3: Configure Variables

Copy the example variables file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

**Open `terraform.tfvars` in a text editor** and change the prefix to something unique:

**On Windows:**
```powershell
notepad terraform.tfvars
```

**On Mac/Linux:**
```bash
nano terraform.tfvars
```

Edit it to look like this:
```hcl
prefix      = "myapp"  # Change this to something unique (lowercase, no spaces)
environment = "sandbox"
region      = "us-east-1"
cost_center = "learning"
```

**💡 Tip**: Use your name or project name for the prefix. Something like "john" or "mylearningproject" works great!

### Step 4: Initialize Terraform

This downloads the Terraform AWS provider and prepares your directory.

```bash
terraform init
```

**Expected output:**
```
Initializing modules...
Initializing provider plugins...
Terraform has been successfully initialized!
```

**✅ If you see this, you're ready to proceed!**

### Step 5: Review the Plan

**Always run this before deploying!** It shows what Terraform will create without actually creating it.

```bash
terraform plan
```

**Expected output:**
```
Plan: 8 to add, 0 to change, 0 to destroy.
  + module.vpc (VPC with subnets, internet gateway)
  + module.s3_bucket (S3 bucket with encryption)
  + aws_security_group.default (Security group)
  + random_id.suffix
```

**💡 Review carefully**: Make sure it shows VPC, S3 bucket, and security group being created!

### Step 6: Deploy Your Infrastructure

**This creates real resources in AWS!** 

```bash
terraform apply
```

**Terraform will ask:**
```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

**Type `yes` and press Enter.**

**Wait 2-3 minutes** - Terraform is creating your resources!

### Step 7: Verify Deployment

**Check that everything worked:**

```bash
# View Terraform outputs
terraform output

# Check resources in AWS
aws ec2 describe-vpcs --vpc-ids $(terraform output -raw vpc_id)
aws s3 ls | grep $(terraform output -raw s3_bucket_name)
aws ec2 describe-security-groups --group-ids $(terraform output -raw security_group_id)
```

**🎉 Congratulations! You just deployed your first AWS infrastructure with Terraform!**

**Want to see it in the AWS Console?**
1. Go to [console.aws.amazon.com](https://console.aws.amazon.com)
2. Navigate to VPC, S3, or EC2 services
3. Look for resources with your prefix name

### Step 8: Clean Up (IMPORTANT!)

**Always destroy resources when you're done** to avoid charges and learn proper cleanup.

```bash
terraform destroy
```

**Terraform will show you what will be deleted:**
```
Plan: 0 to add, 0 to change, 8 to destroy.

Do you really want to destroy all resources?
  Enter a value:
```

**Type `yes` and press Enter.**

**✅ All resources deleted** - No charges incurred!

## Configuration

### Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| prefix | Resource name prefix | "demo" | No |
| environment | Environment (must be "sandbox") | "sandbox" | No |
| suffix | Optional suffix | "" | No |
| region | AWS region | "us-east-1" | No |
| vpc_cidr | VPC CIDR block | "10.0.0.0/16" | No |
| availability_zones | List of AZs | ["us-east-1a", "us-east-1b"] | No |
| public_subnet_cidrs | Public subnet CIDRs | ["10.0.1.0/24", "10.0.2.0/24"] | No |

### Customization Examples

**Different region**:
```hcl
region = "us-west-2"  # Oregon
```

**Single availability zone**:
```hcl
availability_zones = ["us-east-1a"]
public_subnet_cidrs = ["10.0.1.0/24"]
```

**Custom VPC range**:
```hcl
vpc_cidr = "172.16.0.0/16"
public_subnet_cidrs = ["172.16.1.0/24", "172.16.2.0/24"]
```

## Cost Considerations

### Free Tier Usage

This stack stays within AWS free tier:
- ✅ VPC and networking: Always free
- ✅ S3 storage: Free for first 5GB
- ✅ Internet Gateway: Always free
- ✅ Security Groups: Always free

### Staying Free

To avoid charges:
1. **S3 Storage**: Keep data under 5GB
2. **Data Transfer**: First 1GB/month free
3. **No EC2**: This stack doesn't create EC2 instances (no compute costs)
4. **No Private Endpoints**: Using public subnets only

### Cost Alerts

Set up billing alerts in AWS:
```bash
# Create budget alert
aws budgets create-budget \
  --account-id $(aws sts get-caller-identity --query Account --output text) \
  --budget '{
    "BudgetName": "Sandbox-Budget",
    "BudgetLimit": {"Amount": "1.00", "Unit": "USD"},
    "TimeUnit": "MONTHLY",
    "BudgetType": "COST"
  }'
```

## Common Issues & Troubleshooting

**Getting stuck?** This section covers the most common problems beginners face.

### ❌ Issue: Not authenticated

**Error message:**
```
Error: unable to get AWS account ID: InvalidClientTokenId
```

**Solutions:**
1. Run `aws configure` and enter your credentials
2. Check credentials are correct: `aws sts get-caller-identity`
3. Verify IAM permissions to create VPC/S3 resources

### ❌ Issue: Bucket name already exists

**Error message:**
```
Error: bucket name already exists
```

**Solutions:**
1. S3 bucket names must be globally unique
2. The random suffix should handle this, but if it fails:
   ```bash
   # Re-apply to get a new random suffix
   terraform destroy
   terraform apply
   ```

### ❌ Issue: "Access denied"

**Error message:**
```
Error: Access Denied
```

**Solutions:**
1. Check IAM permissions:
   ```bash
   aws sts get-caller-identity
   ```
2. Your IAM user needs permissions for:
   - ec2:CreateVpc, ec2:CreateSubnet, ec2:CreateSecurityGroup
   - ec2:CreateInternetGateway, ec2:CreateRouteTable
   - s3:CreateBucket, s3:PutBucketEncryption

### ❌ Issue: Region not available

**Error message:**
```
Error: region not available
```

**Solutions:**
1. Use a different region:
   ```hcl
   region = "us-east-1"  # Most reliable
   ```

### ✅ General Troubleshooting Steps

**If nothing above works:**

1. **Read the error message** carefully
2. **Check AWS CLI**: Run `aws sts get-caller-identity`
3. **Destroy and retry**:
   ```bash
   terraform destroy
   terraform apply
   ```
4. **Ask for help**: [Open an issue](../../../issues) with your error

### 📞 Still Need Help?

- [Check Getting Started Guide](../../../docs/GETTING_STARTED.md)
- [Read AWS Setup Guide](../../../docs/aws-setup-guide.md)
- [Read Tutorials](../../../docs/TUTORIALS.md)
- [Open a GitHub Issue](../../../issues)
- [Start a Discussion](../../../discussions)

## Next Steps

Now that you've deployed basic infrastructure:

1. **Add EC2 Instance**: Follow the EC2 module examples
2. **Add Private Subnets**: Extend the VPC configuration
3. **Create Another Bucket**: Practice with S3 storage
4. **Explore Modules**: Check out other AWS modules

## Advanced: Adding an EC2 Instance

Want to add a compute instance to this stack? Here's how:

```hcl
# In your main.tf, add after the security group:

module "ec2_instance" {
  source = "../../../modules/aws/ec2-instance"

  name           = "my-web-server"
  use_latest_ami = true  # Auto-detect latest Amazon Linux 2023
  instance_type  = "t2.micro"  # Free tier eligible
  subnet_id      = module.vpc.public_subnet_ids[0]
  security_group_ids = [aws_security_group.default.id]

  tags = module.tags.tags
}

# In outputs.tf, add:
output "ec2_instance_id" {
  value = module.ec2_instance.instance_id
}

output "ec2_public_ip" {
  value = module.ec2_instance.public_ip
}
```

**⚠️ Warning**: EC2 instances cost money! Make sure to destroy when done.

## References

- [AWS Free Tier](https://aws.amazon.com/free/)
- [VPC Documentation](https://docs.aws.amazon.com/vpc/latest/userguide/)
- [S3 Documentation](https://docs.aws.amazon.com/s3/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

---

**Happy Learning!** 🚀

For more examples, check out [AWS Setup Guide](../../../docs/aws-setup-guide.md) or [Tutorials](../../../docs/TUTORIALS.md).

