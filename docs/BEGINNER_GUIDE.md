# Beginner-Friendly Deployment Guide

Need a safe, repeatable way to launch training VMs on AWS or Azure? Follow these steps to get from zero to a running sandbox instance in just a few minutes.

---

## 1. Prep Your Environment

- Install [Terraform ≥ 1.5](https://developer.hashicorp.com/terraform/downloads)
- Install the cloud CLI you need:
  - [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
  - [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- Clone this repository and switch into it:

```bash
git clone https://github.com/Canepro/MyTerraform_Templates.git
cd MyTerraform_Templates
```

---

## 2. Configure Credentials

### AWS

#### Interactive Login (Recommended)
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

#### Using Named Profiles (Best Practice)
```bash
# Add a named profile for your sandbox
aws configure --profile mysandbox
# Enter credentials when prompted

# Use profile with Terraform
export AWS_PROFILE=mysandbox

# Verify
aws sts get-caller-identity --profile mysandbox
```

### Azure

#### Interactive Login (Recommended)
```bash
# Login via browser
az login

# Verify your account
az account show
```

#### Service Principal Login (CI/CD & Automation)
```bash
# Use service principal login
az login --service-principal \
  --username <APP_ID> \
  --password <PASSWORD_OR_CERT> \
  --tenant <TENANT_ID>

# Example:
# az login --service-principal \
#   --username <YOUR_APP_ID> \
#   --password <YOUR_CLIENT_SECRET> \
#   --tenant <YOUR_TENANT_ID>

# Verify
az account show
```

---

## 3. Choose an Environment Profile

| Profile   | Purpose              | AWS Instance | Azure VM Size      |
|-----------|----------------------|--------------|--------------------|
| `dev`     | Free-tier labs       | `t3.micro`   | `Standard_B1s`     |
| `training`| Hands-on workshops   | `t3.medium`  | `Standard_B2ms`    |
| `prod`    | Persistent demos     | `t3.large`   | `Standard_D2s_v3`  |

Each profile also sets disk sizes (30 GB / 50 GB / 100 GB) and keeps default ports 22/80/8080 open unless you override them.

---

## 4. Launch on AWS

### Setup SSH Key

**Option A: Import Existing Key** (if you have a .pem file)
```bash
# Step 1: Copy key from Windows to WSL (fixes permission issues)
cp /mnt/c/Users/i/dev/aws_key.pem ~/.ssh/

# Step 2: Fix permissions
chmod 400 ~/.ssh/aws_key.pem

# Step 3: Verify permissions
ls -la ~/.ssh/aws_key.pem
# Should show: -r-------- (400)

# Step 4: Extract public key
ssh-keygen -y -f ~/.ssh/aws_key.pem > ~/.ssh/aws_key.pub

# Step 5: Import to AWS
aws ec2 import-key-pair \
  --key-name aws_key \
  --public-key-material fileb://~/.ssh/aws_key.pub

# Step 6: Verify import
aws ec2 describe-key-pairs --key-name aws_key
# Should show KeyName: "aws_key" with KeyFingerprint
```

**Check if Key Already Exists**
```bash
# List all your AWS keys
aws ec2 describe-key-pairs --query 'KeyPairs[*].KeyName' --output table

# If your key is already there, skip the import step!
```

**Option B: Create New Key**
```bash
# Create new key pair
aws ec2 create-key-pair \
  --key-name my-aws-key \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/my-aws-key.pem

# Set permissions
chmod 400 ~/.ssh/my-aws-key.pem
```

**Option C: Use AWS Console**
1. Go to **EC2 Dashboard** → **Key Pairs** → **Create key pair**
2. Download the `.pem` file
3. Move to safe location and set permissions: `chmod 400 ~/.ssh/my-key.pem`

### Deploy

```bash
cd stacks/aws/vm
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars and set:
# project_name = "training"
# environment  = "training"
# key_name     = "aws_key"  # Match your imported key name

terraform init

# Best Practice: Use plan files for safety
terraform plan -var-file=terraform.tfvars -out=aws-vm.tfplan

# Review the plan, then apply
terraform apply aws-vm.tfplan
```

**Alternative: Direct apply (faster for dev)**
```bash
terraform apply -var-file=terraform.tfvars
```

Outputs will include:
- `ssh_command`: ready-to-use SSH command
- `public_ip`: the Elastic IP (static by default)
- `jenkins_url`: Jenkins web interface URL
- `docker_installed`: confirmation that Docker is installed
- `jenkins_installed`: confirmation that Jenkins is installed

### Access Jenkins

After deployment, Jenkins is automatically installed and running:

```bash
# 1. Get Jenkins URL
terraform output jenkins_url
# Example output: http://13.216.194.46:8080

# 2. Get initial admin password
ssh -i ~/.ssh/aws_key.pem ubuntu@$(terraform output -raw vm_public_ip) \
  "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"

# 3. Open Jenkins URL in browser and paste the password
```

### Use Docker

Docker is pre-installed and ready to use:

```bash
# SSH to your VM
ssh -i ~/.ssh/aws_key.pem ubuntu@$(terraform output -raw vm_public_ip)

# Check Docker
docker --version
docker ps

# Run a test container
docker run hello-world
```

### Disable Docker or Jenkins (Optional)

If you don't need Docker or Jenkins, you can disable them in your `terraform.tfvars`:

```hcl
# Disable both (saves startup time)
install_docker  = false
install_jenkins = false
```

To tailor access:
```hcl
allowed_ports = [22, 80, 8080]
allowed_cidrs = ["203.0.113.0/24"]
```

Destroy when finished:
```bash
terraform destroy -var-file=terraform.tfvars
```

---

## 5. Launch on Azure

### Setup SSH Key

**Option A: Use Existing Key**
```bash
# Get your public key content
cat ~/.ssh/id_rsa.pub

# Or from Windows path
cat /mnt/c/Users/i/.ssh/id_rsa.pub

# Copy the entire output (starts with ssh-rsa or ssh-ed25519)
```

**Option B: Generate New Key**
```bash
# Generate RSA key (REQUIRED for Azure - only RSA is supported)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure_key

# Get the public key
cat ~/.ssh/azure_key.pub
```

**Important**: Azure Virtual Machines only support RSA SSH keys. Ed25519 keys are not supported.

### Deploy

```bash
cd stacks/azure/vm
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars and set:
# project_name = "training"
# environment  = "training"
# ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ..."  # Paste full key

terraform init

# Best Practice: Use plan files for safety
terraform plan -var-file=terraform.tfvars -out=azure-vm.tfplan

# Review the plan, then apply
terraform apply azure-vm.tfplan
```

**Alternative: Direct apply (faster for dev)**
```bash
terraform apply -var-file=terraform.tfvars
```

Outputs will include:
- `ssh_command`: ready-to-use SSH command
- `public_ip_address`: static Standard SKU public IP
- `jenkins_url`: Jenkins web interface URL
- `docker_installed`: confirmation that Docker is installed
- `jenkins_installed`: confirmation that Jenkins is installed

### Access Jenkins

After deployment, Jenkins is automatically installed and running:

```bash
# 1. Get Jenkins URL
terraform output jenkins_url
# Example output: http://40.121.23.45:8080

# 2. Get initial admin password
ssh azureuser@$(terraform output -raw vm_public_ip) \
  "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"

# 3. Open Jenkins URL in browser and paste the password
```

### Use Docker

Docker is pre-installed and ready to use:

```bash
# SSH to your VM
ssh azureuser@$(terraform output -raw vm_public_ip)

# Check Docker
docker --version
docker ps

# Run a test container
docker run hello-world
```

### Disable Docker or Jenkins (Optional)

If you don't need Docker or Jenkins, you can disable them in your `terraform.tfvars`:

```hcl
# Disable both (saves startup time)
install_docker  = false
install_jenkins = false
```

To change the base image:
```hcl
os_distribution = "azure-linux"  # default is "ubuntu"
```

Destroy when finished:
```bash
terraform destroy -var-file=terraform.tfvars
```

---

## 6. Common Azure VM Issues

### Issue: "Unsupported argument: network_security_group_id"

**Cause**: This module requires Azure Provider v3.0 or higher, which uses the modern `azurerm_network_interface_security_group_association` resource.

**Solution**: The issue is already fixed in this repository. If you see this error in other projects:
- Update to Azure Provider v3.0+
- Replace `network_security_group_id` argument in `azurerm_network_interface` with a separate `azurerm_network_interface_security_group_association` resource

### Issue: "decoding admin_ssh_key.0.public_key for public key data"

**Cause**: Your SSH public key is invalid, a placeholder, or not properly formatted.

**Solution**:
```bash
# Check if you have an existing key
ls -la ~/.ssh/

# Display your public key (Ed25519)
cat ~/.ssh/id_ed25519.pub

# Or RSA key
cat ~/.ssh/id_rsa.pub

# Copy the ENTIRE output (starts with ssh-ed25519 or ssh-rsa)
# Paste it into terraform.tfvars
```

If you don't have an RSA key, generate one:
```bash
# Generate RSA key (REQUIRED - Azure only supports RSA, not Ed25519)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure_key

# Display the public key
cat ~/.ssh/azure_key.pub
```

**Extract public key from existing .pem file**:
```bash
# If you have an existing RSA .pem private key
ssh-keygen -y -f ~/.ssh/azurekey01.pem

# Copy the output (starts with ssh-rsa)
```

**Important**: In `terraform.tfvars`, paste the FULL RSA key content:
```hcl
# ✅ CORRECT - Full RSA key content
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDf60y+HOQwzGbrL5tzv9yZLXER3bvKZLFUO0NiJj+h4xmOkzLbuikGIj/xH+vbB9N2xf2hd2bSAkfqh0hOmi34pvoOJOPyQiGYPrwSbsn79eqldLQaovn4MWeT4QgOHx3McyFIl8XxgavBXn9um4BgJ9BLGTa2IwH8zgSEzM3LgCbvSf7d07hlt7I0jvtj9CaUqiGVi5JRHCxAFPT7+uo1NNqLeGckJXNfDD3MDNQMd1/jUCBpnPWyTetTwUMlpGDk2K7TV99aQHJkkR7ZRKiJLf75+00fFFvvDWSkjMbkVfQTWDU8KTXextAfUQ86EImyrxJh4XFUMVhEVQ9A5oMjbtzXlAr2AzGpYC2IrvhfZgzPvG9r2icnVEP2HabMD0/geOTdebmfO9qakG/wyj7fh5gJGVIghcxg+xDC7p10OgdP7Zy5bX/mP5dsjGJjHlul3vyUABrFLcT22MHAKl6TPD7Yfct3zMV2HHUU9z5/XpxOwOug+0OCwQmwZWPLPeU="

# ❌ WRONG - Ed25519 key (not supported by Azure)
ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAc/c41PTKNLWr86QTUTL4Qd8KAbwtMSGXqY9wDzTCy local-wsl"

# ❌ WRONG - Placeholder
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... your_key_here"

# ❌ WRONG - File path (Azure needs content, not path)
ssh_public_key = "~/.ssh/id_rsa.pub"
```

### Issue: "Terraform has been successfully initialized" but plan fails

**Cause**: Azure provider version mismatch or credential issues.

**Solution**:
```bash
# Re-authenticate with Azure
az login
az account show

# Clear Terraform cache and re-initialize
rm -rf .terraform .terraform.lock.hcl
terraform init
```

---

## 7. Terraform Best Practices

### Use Plan Files (Recommended)
Plan files provide a safety net by separating planning from execution:

```bash
# Generate a plan file
terraform plan -var-file=terraform.tfvars.training -out=training.tfplan

# Review the plan output carefully

# Apply the exact plan
terraform apply training.tfplan

# For destroy operations
terraform plan -destroy -var-file=terraform.tfvars.training -out=destroy.tfplan
terraform apply destroy.tfplan
```

**Benefits:**
- ✅ Review changes before applying
- ✅ Prevents drift between plan and apply
- ✅ Safer for production deployments
- ✅ Can be version-controlled (encrypted)

### Use Variables for Dynamic Values
```bash
# Pass variables at runtime
terraform plan -var="project_name=sandbox01" -out=sandbox.tfplan
terraform apply sandbox.tfplan

# Or use multiple var-files
terraform plan \
  -var-file=terraform.tfvars.training \
  -var="allowed_cidrs=[\"203.0.113.0/24\"]" \
  -out=custom.tfplan
```

---

## 8. General Tips

- **Auto-shutdown**: Enabled by default (approx. 4 hours after apply). Override with `auto_shutdown_hours`, or disable with `enable_auto_shutdown = false`.
- **Cost awareness**: Training profile costs roughly $34/month on AWS and $67/month on Azure if left running 24/7. Use auto-shutdown or destroy when idle.
- **Tag compliance**: Every stack automatically tags resources with `Environment`, `Project`, and `ManagedBy=terraform`.
- **Security**: Replace `allowed_cidrs = ["0.0.0.0/0"]` with your corporate CIDR blocks before exposing services.
- **Named profiles**: Use AWS named profiles (`--profile mysandbox`) to separate credentials for different projects.

---

## Need More Detail?

- Refer to the stack READMEs under `stacks/aws/vm` and `stacks/azure/vm`.
- Check `modules/aws/ec2-instance` and `modules/azure/virtual-machine` READMEs for module-level options.
- Read `docs/UNIFIED_INTERFACE.md` to understand the cross-cloud design.
- Dive into `docs/QUICK_DEPLOY.md` for advanced scenarios (backups, multi-AZ, load balancers).

When in doubt, run `terraform plan` to preview changes before deploying. Happy sandboxing!

