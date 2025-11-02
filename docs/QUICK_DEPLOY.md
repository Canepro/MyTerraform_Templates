# Quick Deploy Guide

Deploy ready-to-use VMs in Azure, AWS, or GCP in under 3 minutes with SSH access configured. Perfect for development, testing, or any quick compute needs.

## 🎯 Purpose

This guide helps you:
- Deploy a fully-configured VM in 2-3 minutes
- Get SSH access immediately after deployment
- Understand costs before deploying
- Clean up resources with one command

## 📋 What You Get

Each quick-deploy stack creates:
- ✅ VPC/VNet with proper networking
- ✅ Security groups/firewalls with SSH enabled
- ✅ Public IP for internet access
- ✅ Latest Ubuntu/Amazon Linux
- ✅ SSH access configured and ready

## 🚀 Azure Quick Deploy

### Deploy Azure VM

```bash
cd stacks/azure/vm

# 1. Configure variables
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Add your SSH public key

# 2. Login to Azure
az login

# 3. Deploy
terraform init
terraform apply

# 4. Connect via SSH
ssh azureuser@$(terraform output -raw vm_public_ip)

# 5. Destroy when done
terraform destroy
```

### Cost: ~$12/month

**Details**: See [Azure VM README](stacks/azure/vm/README.md)

## ☁️ AWS Quick Deploy

### Deploy AWS EC2 Instance

```bash
cd stacks/aws/vm

# 1. Create SSH key pair in AWS Console
# Go to EC2 Dashboard > Key Pairs > Create Key Pair
# Download the .pem file and set permissions: chmod 400 key.pem

# 2. Configure variables
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Add your key pair name and path

# 3. Configure AWS credentials
aws configure

# 4. Deploy
terraform init
terraform apply

# 5. Connect via SSH
terraform output ssh_command
# Or copy the output command directly

# 6. Destroy when done
terraform destroy
```

### Cost: FREE (Free Tier Eligible)

**Details**: See [AWS VM README](stacks/aws/vm/README.md)

## 🌐 GCP Quick Deploy

### Deploy GCP Compute Engine Instance

```bash
cd stacks/gcp/vm

# 1. Setup GCP project
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
gcloud services enable compute.googleapis.com

# 2. Generate SSH key
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# 3. Configure variables
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars  # Add project ID and SSH public key

# 4. Deploy
terraform init
terraform apply

# 5. Connect via SSH
ssh ubuntu@$(terraform output -raw vm_public_ip)

# 6. Destroy when done
terraform destroy
```

### Cost: FREE (Free Tier Eligible)

**Details**: See [GCP VM README](stacks/gcp/vm/README.md)

## 📊 Quick Comparison

| Provider | Cost/Month | Free Tier | Setup Time | Default OS |
|----------|------------|-----------|------------|------------|
| **Azure** | ~$12 | No | 2-3 min | Ubuntu 22.04 LTS |
| **AWS** | FREE* | Yes | 2-3 min | Amazon Linux 2023 |
| **GCP** | FREE* | Yes | 2-3 min | Ubuntu 22.04 LTS |

\* Free tier eligible (AWS: 750 hrs/month, GCP: $300 credit)

## 🔑 SSH Key Setup

### Azure & GCP
Generate an SSH key and paste the **public key** into `terraform.tfvars`:

```bash
# Generate key
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
# Press Enter to use default location: ~/.ssh/id_rsa

# Display your public key
cat ~/.ssh/id_rsa.pub
# Copy the output to terraform.tfvars
```

### AWS
Create a key pair in AWS and provide the **path** to the downloaded `.pem` file:

```bash
# Option 1: AWS Console
# Go to EC2 Dashboard > Key Pairs > Create Key Pair > Download .pem file

# Option 2: AWS CLI
aws ec2 create-key-pair --key-name my-key --query 'KeyMaterial' --output text > ~/.ssh/my-key.pem
chmod 400 ~/.ssh/my-key.pem

# Then in terraform.tfvars:
# key_name = "my-key"
# key_path = "~/.ssh/my-key.pem"
```

## 🎯 Common Use Cases

### Development Environment

```bash
# Deploy, work, destroy
cd stacks/aws/vm
terraform apply
# ... do your work ...
terraform destroy
```

### Testing New Software

```bash
# Spawn VM, test, tear down
cd stacks/gcp/vm
terraform apply
ssh ubuntu@$(terraform output -raw vm_public_ip)
# ... test your app ...
terraform destroy
```

### Quick Experimentation

```bash
# Try something, destroy when done
cd stacks/azure/vm
terraform apply
# ... experiment ...
terraform destroy  # Always clean up!
```

## 💰 Cost Management Tips

### 1. Use Free Tier

- **AWS**: t3.micro is free for 750 hrs/month
- **GCP**: e2-micro is free with $300 credit

### 2. Enable Auto-Shutdown (Azure)

```hcl
enable_auto_shutdown = true
auto_shutdown_time   = "1900"  # Shutdown at 7 PM daily
```

### 3. Always Destroy

```bash
# When done working
terraform destroy
```

### 4. Monitor Costs

- **Azure**: Set budget alerts in Azure Portal
- **AWS**: Set up AWS Cost Explorer alerts
- **GCP**: Set budget alerts in GCP Console

## 🔍 Troubleshooting

### SSH Connection Issues

```bash
# Test SSH key
ssh-add -l  # Check if key is loaded

# Test connection
ssh -v user@IP_ADDRESS  # Verbose output

# Common issues:
# - Wrong username (ubuntu vs ec2-user vs azureuser)
# - Key not loaded in ssh-agent
# - VM still booting (wait 1-2 minutes)
```

### Terraform Errors

```bash
# Re-initialize if needed
terraform init -upgrade

# Check provider authentication
# Azure: az login
# AWS: aws configure
# GCP: gcloud auth login
```

### Already Exists Errors

```bash
# Destroy and retry
terraform destroy
terraform apply
```

## 📚 Next Steps

After you've deployed your first VM:

1. **Explore Modules**: Check out individual modules in `modules/azure/`, `modules/aws/`, `modules/gcp/`
2. **Build Custom Stacks**: Combine modules to create your own stacks
3. **Multi-Cloud**: Try deploying to all three providers
4. **Production Stacks**: Look at `stacks/*/sandbox` for more complete setups

## 🔗 Resources

### Azure
- [Azure VM README](stacks/azure/vm/README.md)
- [Azure Getting Started](docs/GETTING_STARTED.md#azure-beginner-guide-recommended)
- [Azure Pricing](https://azure.microsoft.com/pricing/)

### AWS
- [AWS VM README](stacks/aws/vm/README.md)
- [AWS Setup Guide](docs/aws-setup-guide.md)
- [AWS Pricing](https://aws.amazon.com/pricing/)

### GCP
- [GCP VM README](stacks/gcp/vm/README.md)
- [GCP Setup Guide](docs/gcp-setup-guide.md)
- [GCP Pricing](https://cloud.google.com/pricing/)

## 🤝 Getting Help

- Check provider-specific README in each stack folder
- Review [Troubleshooting](#troubleshooting) section
- [Open an issue](https://github.com/Canepro/MyTerraform_Templates/issues)
- [Ask in discussions](https://github.com/Canepro/MyTerraform_Templates/discussions)

## ⚡ Quick Commands Reference

```bash
# Deploy
terraform init
terraform apply

# Get outputs
terraform output vm_public_ip
terraform output ssh_command

# Destroy
terraform destroy

# Plan changes
terraform plan

# Format code
terraform fmt

# Validate configuration
terraform validate
```

## 🎓 Learning Path

1. **Start Here**: Deploy a VM in your preferred provider (2-3 min)
2. **Try All Three**: Experience AWS, Azure, and GCP (10-15 min)
3. **Explore Modules**: Look at individual resource modules
4. **Build Stacks**: Create custom configurations
5. **Go Multi-Cloud**: Deploy across multiple providers

## 📝 Notes

- All stacks use the cheapest configurations by default
- Networking, security, and SSH are pre-configured
- Resources are designed for easy deployment and destruction
- Always run `terraform destroy` when done to avoid charges
- Free tier eligibility varies by provider and account age

---

**Ready to deploy?** Choose a provider above and follow the steps!

**Questions?** Check the provider-specific README or [open an issue](https://github.com/Canepro/MyTerraform_Templates/issues).
