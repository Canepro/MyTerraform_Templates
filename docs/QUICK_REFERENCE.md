# Quick Reference Card

Fast lookup for common commands and patterns.

---

## 🔐 Credential Setup

### AWS

```bash
# Interactive configuration
aws configure
aws sts get-caller-identity

# Named profile (recommended)
aws configure --profile mysandbox
export AWS_PROFILE=mysandbox
aws sts get-caller-identity --profile mysandbox
```

### Azure

```bash
# Interactive login
az login
az account show

# Service principal (automation)
az login --service-principal \
  --username <APP_ID> \
  --password <PASSWORD> \
  --tenant <TENANT_ID>
```

---

## 🚀 Deployment Workflow

### Standard Workflow (Recommended)

```bash
cd stacks/{aws|azure}/vm

# Initialize
terraform init

# Plan with output file
terraform plan -var-file=terraform.tfvars.training -out=training.tfplan

# Review the plan, then apply
terraform apply training.tfplan

# Destroy with plan
terraform plan -destroy -var-file=terraform.tfvars.training -out=destroy.tfplan
terraform apply destroy.tfplan
```

### Quick Workflow (Dev/Testing)

```bash
# Direct apply
terraform apply -var-file=terraform.tfvars.dev

# Direct destroy
terraform destroy -var-file=terraform.tfvars.dev
```

### Dynamic Variables

```bash
# Override variables at runtime
terraform plan \
  -var="project_name=sandbox01" \
  -var="environment=training" \
  -var="allowed_cidrs=[\"203.0.113.0/24\"]" \
  -out=custom.tfplan

terraform apply custom.tfplan
```

---

## 📊 Environment Profiles

| Profile | AWS Instance | Azure VM | Disk | Cost (AWS) | Cost (Azure) |
|---------|--------------|----------|------|------------|--------------|
| **dev** | t3.micro | Standard_B1s | 30GB | ~$10/mo | ~$13/mo |
| **training** | t3.medium | Standard_B2ms | 50GB | ~$34/mo | ~$67/mo |
| **prod** | t3.large | Standard_D2s_v3 | 100GB | ~$69/mo | ~$105/mo |

*With 4-hour auto-shutdown, training costs drop to ~$11/mo (AWS) and ~$22/mo (Azure)*

---

## 🔑 SSH Key Setup

### AWS

**Import Existing Key** (if you have a .pem file)
```bash
# Extract public key
ssh-keygen -y -f /mnt/c/Users/i/dev/aws_key.pem > ~/.ssh/aws_key.pub

# Import to AWS
aws ec2 import-key-pair \
  --key-name aws_key \
  --public-key-material fileb://~/.ssh/aws_key.pub

# Verify
aws ec2 describe-key-pairs --key-name aws_key

# Use in terraform.tfvars
key_name = "aws_key"
```

**Create New Key**
```bash
# Create key pair
aws ec2 create-key-pair \
  --key-name my-key \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/my-key.pem

chmod 400 ~/.ssh/my-key.pem

# Use in terraform.tfvars
key_name = "my-key"
```

**List Existing Keys**
```bash
aws ec2 describe-key-pairs --query 'KeyPairs[*].KeyName' --output table
```

**Verify Key Setup**
```bash
# Check if key exists in WSL
ls -la ~/.ssh/aws_key.pem

# Check if key is in AWS
aws ec2 describe-key-pairs --key-name aws_key

# Quick verification one-liner
[ -f ~/.ssh/aws_key.pem ] && echo "✅ Key in WSL" || echo "❌ Not found"
aws ec2 describe-key-pairs --key-name aws_key &>/dev/null && echo "✅ Key in AWS" || echo "❌ Not imported"
```

**Fix Permission Issues (Windows/WSL)**
```bash
# Copy from Windows to WSL
cp /mnt/c/Users/i/dev/aws_key.pem ~/.ssh/

# Fix permissions
chmod 400 ~/.ssh/aws_key.pem

# Verify
ls -la ~/.ssh/aws_key.pem
# Should show: -r-------- (400)
```

### Azure

**Use Existing Key**
```bash
# Get public key content
cat ~/.ssh/id_rsa.pub
# Or: cat /mnt/c/Users/i/.ssh/id_rsa.pub

# Copy entire output to terraform.tfvars
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2E..."
```

**Generate New Key**
```bash
# RSA (recommended)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure_key

# Or Ed25519 (modern)
ssh-keygen -t ed25519 -f ~/.ssh/azure_key

# Get public key
cat ~/.ssh/azure_key.pub

# Use in terraform.tfvars
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2E..."
```

---

## 🛡️ Security Patterns

### Restrict Access to Corporate Network

```hcl
# terraform.tfvars
allowed_ports = [22, 80, 8080]
allowed_cidrs = ["10.0.0.0/8", "172.16.0.0/12"]
```

### SSH Only (Remove Web Ports)

```hcl
allowed_ports = [22]
allowed_cidrs = ["203.0.113.0/24"]
```

### No Public Access (Azure Bastion)

```hcl
enable_public_ip = false  # Azure only
# Deploy Azure Bastion separately
```

---

## 📋 Common Terraform Commands

```bash
# Initialize (required after cloning or module changes)
terraform init

# Validate syntax
terraform validate

# Format code
terraform fmt

# Show current state
terraform show

# List resources
terraform state list

# Get specific output
terraform output vm_public_ip
terraform output -raw ssh_command

# Refresh state
terraform refresh

# Import existing resource
terraform import module.ec2_vm.aws_instance.this i-1234567890abcdef0

# Taint resource (force recreation)
terraform taint module.ec2_vm.aws_instance.this

# Untaint resource
terraform untaint module.ec2_vm.aws_instance.this
```

---

## 🔍 Troubleshooting

### AWS

```bash
# Verify credentials
aws sts get-caller-identity

# List key pairs
aws ec2 describe-key-pairs --region us-east-1

# Check instance status
aws ec2 describe-instances --instance-ids i-1234567890abcdef0

# Get console output
aws ec2 get-console-output --instance-id i-1234567890abcdef0
```

### Azure

```bash
# Verify login
az account show

# List VMs
az vm list --output table

# Check VM status
az vm show --resource-group rg-quickvm-training --name quickvm-vm

# Get boot diagnostics
az vm boot-diagnostics get-boot-log \
  --resource-group rg-quickvm-training \
  --name quickvm-vm

# Deallocate VM (stop billing)
az vm deallocate --resource-group rg-quickvm-training --name quickvm-vm
```

---

## 💰 Cost Management

### AWS

```bash
# Set up budget alert
aws budgets create-budget \
  --account-id 123456789012 \
  --budget file://budget.json

# Check current costs
aws ce get-cost-and-usage \
  --time-period Start=2025-11-01,End=2025-11-30 \
  --granularity MONTHLY \
  --metrics BlendedCost
```

### Azure

```bash
# Check consumption
az consumption usage list \
  --start-date 2025-11-01 \
  --end-date 2025-11-30

# Set budget (requires subscription scope)
az consumption budget create \
  --budget-name monthly-limit \
  --amount 100 \
  --time-grain Monthly
```

---

## 🧹 Cleanup

### Remove All Resources

```bash
# AWS
cd stacks/aws/vm
terraform destroy -var-file=terraform.tfvars.training

# Azure
cd stacks/azure/vm
terraform destroy -var-file=terraform.tfvars.training
```

### Remove Terraform State

```bash
# Clean local state (after destroy)
rm -rf .terraform .terraform.lock.hcl
rm -f terraform.tfstate terraform.tfstate.backup
rm -f *.tfplan
```

---

## 📚 Documentation Links

- [Beginner's Guide](./BEGINNER_GUIDE.md)
- [Unified Interface](./UNIFIED_INTERFACE.md)
- [AWS Module](../modules/aws/ec2-instance/README.md)
- [Azure Module](../modules/azure/virtual-machine/README.md)
- [AWS Stack](../stacks/aws/vm/README.md)
- [Azure Stack](../stacks/azure/vm/README.md)

---

**Quick Reference** | **Copy-Paste Ready** | **Production Patterns**

