# Getting Started Guide for Absolute Beginners

Welcome! This guide will walk you through deploying your first cloud infrastructure in just **10 minutes**.

## 🎯 What You'll Learn

By the end of this guide, you will have:
- ✅ Created a cloud account
- ✅ Deployed a resource group, storage, and virtual network
- ✅ Learned basic Terraform commands
- ✅ Spent $0.00 (all free tier resources)

**Bonus**: When you're ready, our VM stacks come with Docker and Jenkins pre-installed!

## 📋 Prerequisites Checklist

Before we start, make sure you have:

- [ ] **A computer** (Windows, Mac, or Linux)
- [ ] **Internet connection**
- [ ] **Credit card** (won't be charged, just for verification)
- [ ] **Email address**
- [ ] **Basic terminal/command line knowledge** (we'll guide you!)

## 🚀 Choose Your First Cloud Platform

We recommend **Azure** for complete beginners because:
- ✅ Easiest account setup
- ✅ Most generous free tier
- ✅ Great documentation
- ✅ Excellent free learning resources

**Already have an AWS account?** Jump to the [AWS section](#aws-beginner-guide).  
**Want to use GCP?** Jump to the [GCP section](#gcp-beginner-guide).

## 🎓 Azure Beginner Guide (Recommended)

### Step 1: Install Required Tools (15 minutes)

#### 1.1 Install Git

**Windows:**
1. Download from [git-scm.com](https://git-scm.com/download/win)
2. Run installer with default settings
3. Restart your computer

**Mac:**
```bash
# Install Homebrew first (if you don't have it)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Then install Git
brew install git
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install git
```

**Verify installation:**
```bash
git --version
# Should show: git version 2.x.x
```

#### 1.2 Install Terraform

**Windows:**
1. Download from [terraform.io/downloads](https://www.terraform.io/downloads)
2. Choose Windows 64-bit ZIP
3. Extract to `C:\Program Files\Terraform`
4. Add to PATH:
   - Search "Environment Variables" in Start menu
   - Click "Environment Variables"
   - Under "System Variables", find "Path" and click "Edit"
   - Click "New" and add: `C:\Program Files\Terraform`
   - Click "OK" on all windows
   - Restart terminal

**Mac:**
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

**Linux (Ubuntu/Debian):**
```bash
# Add HashiCorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -

# Add HashiCorp repository
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# Install Terraform
sudo apt update
sudo apt install terraform
```

**Verify installation:**
```bash
terraform version
# Should show: Terraform v1.5.0 or higher
```

#### 1.3 Install Azure CLI

**Windows:**
```powershell
# Run PowerShell as Administrator
winget install -e --id Microsoft.AzureCLI
```

**Mac:**
```bash
brew install azure-cli
```

**Linux:**
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

**Verify installation:**
```bash
az --version
# Should show azure-cli version 2.x.x
```

### Step 2: Create Azure Account (5 minutes)

1. Go to [azure.microsoft.com/free](https://azure.microsoft.com/free)
2. Click **Start Free**
3. Sign in with your Microsoft account (or create one)
4. Fill in your details:
   - First name, last name
   - Phone number
   - Country
5. Verify your identity:
   - Enter your phone number
   - You'll receive a text code
   - Enter the code
6. Enter credit card info:
   - **Don't worry** - you won't be charged unless you explicitly upgrade
   - Required for identity verification only
7. Check **Agree to terms**
8. Click **Sign up**

**Congratulations!** You now have an Azure account with:
- ✅ $200 free credit for 30 days
- ✅ Free services for 12 months
- ✅ 50+ always-free services

### Step 3: Log Into Azure (1 minute)

Open your terminal and run:
```bash
az login
```

This will:
1. Open your web browser
2. Ask you to sign in (use your Azure account)
3. Return to your terminal when done

**Verify you're logged in:**
```bash
az account show
```

You should see your Azure subscription details.

### Step 4: Deploy Your First Infrastructure (5 minutes)

#### 4.1 Clone the Repository

```bash
# Navigate to where you want to work
cd ~/Desktop  # or wherever you keep projects

# Clone the repository
git clone https://github.com/Canepro/MyTerraform_Templates.git

# Navigate into the project
cd MyTerraform_Templates
```

#### 4.2 Configure Your Deployment

```bash
# Navigate to the sandbox stack
cd stacks/azure/sandbox

# Copy the example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit the configuration file
```

**On Windows:**
```powershell
notepad terraform.tfvars
```

**On Mac/Linux:**
```bash
nano terraform.tfvars
```

Change the values to something unique:
```hcl
prefix      = "myfirstproject"  # Change this to something unique
environment = "sandbox"
location    = "eastus"          # You can keep this
cost_center = "learning"
```

Save and close the file.

#### 4.3 Deploy Your Infrastructure

```bash
# Step 1: Initialize Terraform
terraform init

# You'll see: "Terraform has been successfully initialized!" ✅

# Step 2: Preview what will be created
terraform plan

# You'll see a plan showing:
# + 3 modules to add
# - resource_group
# - storage_account  
# - virtual_network
# Total cost: $0.00 ✅

# Step 3: Apply the configuration
terraform apply

# Terraform will ask: "Do you want to perform these actions?"
# Type: yes
# Press: Enter
```

**Sit back and watch the magic! ✨**

In about 2 minutes, you'll have:
- ✅ A resource group
- ✅ A storage account
- ✅ A virtual network with 2 subnets
- ✅ All completely FREE!

#### 4.4 Verify Your Deployment

```bash
# List your resources
az group list --query "[?name=='rg-myfirstproject-sandbox']"

# Check your storage account
az storage account list --query "[?resourceGroup=='rg-myfirstproject-sandbox']"

# Check your virtual network
az network vnet list --query "[?resourceGroup=='rg-myfirstproject-sandbox']"

# View Terraform outputs
terraform output
```

**Congratulations! You've deployed your first infrastructure! 🎉**

### Step 5: Understanding What You Created

Let's break down what you just deployed:

#### Resource Group (`rg-myfirstproject-sandbox`)
- **What it is**: A container for all your Azure resources
- **Cost**: FREE forever ✅
- **Why it matters**: Helps organize and manage resources together

#### Storage Account (`stmyfirstprojectsandbox`)
- **What it is**: Cloud storage for files, images, backups
- **Cost**: FREE for first 5GB ✅
- **Features**:
  - Encrypted by default
  - Redundant storage
  - HTTPS only

#### Virtual Network (`vnet-myfirstproject-sandbox`)
- **What it is**: Your private network in the cloud
- **Cost**: FREE forever ✅
- **What's inside**:
  - Subnet for default resources (10.0.1.0/24)
  - Subnet for applications (10.0.2.0/24)
  - Service endpoints for secure connections

### Step 6: Clean Up (Save Money)

When you're done experimenting:

```bash
# Destroy all resources
terraform destroy

# Terraform will ask: "Do you want to destroy all resources?"
# Type: yes
# Press: Enter
```

**All resources deleted** - No charges! ✅

### Step 7: Next Steps

Now that you've deployed your first infrastructure:

1. **Explore More Modules**: Check out [Available Modules](../../README.md#available-modules)
2. **Learn Terraform**: Try the [official tutorials](https://learn.hashicorp.com/tutorials/terraform/azure-build)
3. **Deploy a VM**: Follow the [Virtual Machine module guide](../modules/azure/virtual-machine/README.md)
4. **Join the Community**: [Open an issue](../../issues) to ask questions

## 🌍 AWS Beginner Guide

If you prefer AWS or already have an account, follow these steps:

### Step 1: Install AWS CLI

**Windows:**
```powershell
# Using MSI installer
# Download from: https://awscli.amazonaws.com/AWSCLIV2.msi

# Or using winget
winget install Amazon.AWSCLI
```

**Mac:**
```bash
brew install awscli
```

**Linux:**
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### Step 2: Create AWS Account

1. Go to [aws.amazon.com](https://aws.amazon.com)
2. Click **Create an AWS Account**
3. Follow the sign-up process
4. Verify with phone number
5. Enter credit card (won't be charged within free tier)
6. Choose **Basic Support** (Free)

**You now have:**
- ✅ 750 hours/month EC2 t2.micro (FREE for 12 months)
- ✅ 5GB S3 storage (FREE)
- ✅ 1M Lambda requests/month (FREE)

### Step 3: Configure AWS CLI

```bash
# Configure your credentials
aws configure

# You'll need:
# - AWS Access Key ID (get from AWS Console → IAM → Users → Your User → Security Credentials)
# - AWS Secret Access Key
# - Default region: us-east-1
# - Default output format: json

# Verify
aws sts get-caller-identity
```

### Step 4: Create Your First Stack

Since AWS doesn't have a ready-made sandbox stack yet, you can create one:

```bash
# Navigate to AWS modules
cd modules/aws

# Create a simple S3 bucket configuration
cat > test-s3.tf << 'EOF'
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

module "s3_bucket" {
  source = "../modules/aws/s3-bucket"
  
  bucket_name = "my-first-bucket-$(date +%s)"
  
  tags = {
    environment = "test"
    managed_by  = "terraform-beginner"
  }
}

output "bucket_name" {
  value = module.s3_bucket.bucket_name
}
EOF

# Initialize and deploy
terraform init
terraform plan
terraform apply  # Type 'yes' when prompted
```

**Clean up:**
```bash
terraform destroy  # Type 'yes' when prompted
```

**Complete AWS Guide**: See [AWS Setup Guide](aws-setup-guide.md) for detailed instructions.

## ☁️ GCP Beginner Guide

For those who want to use Google Cloud Platform:

### Step 1: Install Google Cloud SDK

**Windows:**
```powershell
# Download from: https://cloud.google.com/sdk/docs/install
# Run the installer
```

**Mac:**
```bash
brew install --cask google-cloud-sdk
```

**Linux:**
```bash
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
```

### Step 2: Create GCP Account

1. Go to [cloud.google.com](https://cloud.google.com)
2. Click **Get Started for Free**
3. Sign in with Google account
4. Enter credit card (won't be charged initially)
5. Complete setup

**You now have:**
- ✅ $300 free credit for 90 days
- ✅ Always-free tier services
- ✅ Access to all products

### Step 3: Create Project and Authenticate

```bash
# Create a project
export PROJECT_ID="my-first-terraform-project"
gcloud projects create $PROJECT_ID

# Link billing
gcloud beta billing projects link $PROJECT_ID \
  --billing-account=$(gcloud beta billing accounts list --format='value(name)' --limit=1)

# Authenticate
gcloud auth login
```

**Complete GCP Guide**: See [GCP Setup Guide](gcp-setup-guide.md) for detailed instructions.

## ❓ Common Questions

### "What is Terraform?"

Terraform is a tool that lets you describe your cloud infrastructure in code. Instead of clicking buttons in a web portal, you write configuration files.

### "Why learn Terraform?"

- **Repeatable**: Deploy the same infrastructure anywhere
- **Version controlled**: Track changes like code
- **Scalable**: Manage 10 or 10,000 resources
- **Standardized**: One language for all clouds
- **Industry standard**: Used by top tech companies

### "Will I be charged?"

**No!** Our sandbox examples use only free-tier resources:
- ✅ Resource Groups: FREE forever
- ✅ Virtual Networks: FREE forever  
- ✅ Storage: FREE first 5GB
- ✅ Sandbox stacks: $0.00/month

**Important**: Always run `terraform destroy` when done to clean up!

### "What if something breaks?"

Don't worry! That's normal. Here's what to do:

1. **Read the error message**: It usually tells you what's wrong
2. **Check the logs**: Look at the last few lines of output
3. **Destroy and retry**: Run `terraform destroy`, fix the issue, try again
4. **Ask for help**: [Open an issue](../../issues) with your error message

### "I don't have a credit card"

For learning purposes, you can:
- Use a prepaid gift card
- Use a virtual credit card from privacy.com
- Ask your organization if they have a cloud account for learning

**But remember**: With free tier, you won't be charged anyway!

### "How do I learn more?"

1. **Practice**: Deploy, destroy, and redeploy
2. **Read**: Check module READMEs for examples
3. **Experiment**: Try modifying configurations
4. **Learn**: [Terraform Learn Platform](https://learn.hashicorp.com/terraform)
5. **Ask**: [GitHub Discussions](../../discussions)

## 🎓 Learning Path

### Week 1: Basics
- [x] Deploy your first sandbox
- [ ] Understand resource groups/regions
- [ ] Learn `terraform init`, `plan`, `apply`, `destroy`
- [ ] Practice cleanup

### Week 2: Storage
- [ ] Deploy a storage account
- [ ] Upload and download files
- [ ] Configure encryption
- [ ] Set up versioning

### Week 3: Networking
- [ ] Create virtual networks
- [ ] Configure subnets
- [ ] Set up security groups
- [ ] Connect resources

### Week 4: Compute
- [ ] Deploy a virtual machine
- [ ] SSH into your VM
- [ ] Configure firewalls
- [ ] Set up auto-shutdown
- [ ] Access pre-installed Docker and Jenkins
- [ ] Run your first Docker container
- [ ] Set up your first Jenkins pipeline

### Month 2: Advanced Topics
- Learn multi-cloud deployments
- Set up CI/CD pipelines
- Implement state management
- Build production-ready stacks

## 🚨 Important Safety Tips

### 1. Always Use the Sandbox First
Don't deploy production resources until you're comfortable with basics.

### 2. Set Budget Alerts
Even with free tier, set up billing alerts:
- **Azure**: [Set Budget Alert](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/tutorial-acm-create-budgets)
- **AWS**: [Set Budget Alert](https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-create.html)
- **GCP**: [Set Budget Alert](https://cloud.google.com/billing/docs/how-to/budgets)

### 3. Always Destroy Resources
When done experimenting:
```bash
terraform destroy
```

### 4. Never Commit Sensitive Data
Don't put these in git:
- ❌ Passwords
- ❌ API keys
- ❌ terraform.tfvars (with real values)
- ❌ terraform.tfstate files

Use `.gitignore` to prevent accidental commits.

## 🔧 Common Issues & Solutions

### Azure: "Unsupported argument: network_security_group_id"

**What happened**: Azure Provider v3.0+ changed how network security groups attach to network interfaces.

**Solution**: This is already fixed in this repository. We use the modern `azurerm_network_interface_security_group_association` resource.

### Azure: SSH Key Decoding Error

**Error**: `decoding "admin_ssh_key.0.public_key" for public key data`

**Cause**: Your SSH public key in `terraform.tfvars` is a placeholder or invalid.

**Fix**:
```bash
# Check for existing keys
ls -la ~/.ssh/

# Display your Ed25519 public key
cat ~/.ssh/id_ed25519.pub

# Or RSA public key
cat ~/.ssh/id_rsa.pub

# Copy the ENTIRE output and paste into terraform.tfvars
```

**Example valid SSH key in terraform.tfvars**:
```hcl
# ✅ CORRECT - RSA key (Azure only supports RSA, not Ed25519)
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDf60y+HOQwzGbrL5tzv9yZLXER3bvKZLFUO0NiJj+h4xmOkzLbuikGIj/xH+vbB9N2xf2hd2bSAkfqh0hOmi34pvoOJOPyQiGYPrwSbsn79eqldLQaovn4MWeT4QgOHx3McyFIl8XxgavBXn9um4BgJ9BLGTa2IwH8zgSEzM3LgCbvSf7d07hlt7I0jvtj9CaUqiGVi5JRHCxAFPT7+uo1NNqLeGckJXNfDD3MDNQMd1/jUCBpnPWyTetTwUMlpGDk2K7TV99aQHJkkR7ZRKiJLf75+00fFFvvDWSkjMbkVfQTWDU8KTXextAfUQ86EImyrxJh4XFUMVhEVQ9A5oMjbtzXlAr2AzGpYC2IrvhfZgzPvG9r2icnVEP2HabMD0/geOTdebmfO9qakG/wyj7fh5gJGVIghcxg+xDC7p10OgdP7Zy5bX/mP5dsjGJjHlul3vyUABrFLcT22MHAKl6TPD7Yfct3zMV2HHUU9z5/XpxOwOug+0OCwQmwZWPLPeU="

# ❌ WRONG - Ed25519 key (not supported by Azure)
ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAc/c41PTKNLWr86QTUTL4Qd8KAbwtMSGXqY9wDzTCy user@host"

# ❌ WRONG - Placeholder text
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... your_key_here"
```

**Important**: Azure Virtual Machines only support RSA SSH keys. Generate an RSA key with:
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure_key
```

### AWS: Key Pair Not Found

**Error**: `The key pair 'my-key' does not exist`

**Fix**:
```bash
# List your existing keys
aws ec2 describe-key-pairs --query 'KeyPairs[*].KeyName' --output table

# Import your existing key
aws ec2 import-key-pair \
  --key-name my-key \
  --public-key-material fileb://~/.ssh/id_rsa.pub
```

### Terraform: Module Not Found

**Error**: `Module not found: module.resource_group`

**Fix**:
```bash
# Re-initialize to download modules
terraform init

# If still failing, clear cache
rm -rf .terraform .terraform.lock.hcl
terraform init
```

## 📚 Additional Resources

### Official Documentation
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

### Learning Resources
- [Terraform Learn](https://learn.hashicorp.com/terraform): Free interactive tutorials
- [Azure Learn](https://learn.microsoft.com/en-us/azure/): Microsoft's free training
- [AWS Training](https://aws.amazon.com/training/): Amazon's free courses
- [GCP Training](https://cloud.google.com/training): Google's free training

### Community
- [Terraform Discord](https://discord.gg/hashicorp)
- [r/Terraform](https://reddit.com/r/Terraform)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/terraform)

## 🎉 Congratulations!

You've completed the beginner's guide! You now know:
- ✅ How to set up cloud accounts
- ✅ How to install required tools
- ✅ How to deploy infrastructure
- ✅ How to clean up safely

**What's next?**
1. Explore the [module READMEs](../modules/) for more examples
2. Try deploying a virtual machine
3. Experiment with different configurations
4. Join our community discussions

**Questions? Need help?**
- [Open an issue](../../issues)
- [Start a discussion](../../discussions)
- Read the [FAQ](contributing.md#faq)

---

**Remember**: Everyone starts as a beginner. The key is to practice, experiment, and ask questions. Happy Terraforming! 🚀

