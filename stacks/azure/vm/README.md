# Azure VM Stack

Deploy a production-ready Azure Linux VM using the unified module interface with environment-driven defaults, auto-shutdown, and configurable security.

## 🎯 Quick Deploy

```bash
cd stacks/azure/vm

# Copy and edit configuration
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars and set your ssh_public_key

# Deploy with training profile
terraform init
terraform apply

# Or use a specific environment profile
terraform apply -var-file=terraform.tfvars.dev
terraform apply -var-file=terraform.tfvars.training
terraform apply -var-file=terraform.tfvars.prod
```

## 🏗️ What Gets Created

This stack provisions:

- ✅ **Resource Group** for logical grouping
- ✅ **Virtual Network** (10.0.0.0/16)
- ✅ **Subnet** (10.0.1.0/24)
- ✅ **Network Security Group** with configurable ports (22, 80, 8080 by default)
- ✅ **Linux VM** with environment-specific sizing (via module)
- ✅ **Public IP** (optional, enabled by default)
- ✅ **Auto-shutdown schedule** (4-hour default for sandbox safety)
- ✅ **Docker** (installed by default, can be disabled)
- ✅ **Jenkins** (installed by default via Docker, can be disabled)

## 📊 Environment Profiles

| Environment | VM Size | OS Disk | Auto-Shutdown | Use Case |
|-------------|---------|---------|---------------|----------|
| **dev** | Standard_B1s | 30GB | ✅ 4 hours | Cost-effective labs |
| **training** | Standard_B2ms | 50GB | ✅ 4 hours | Classroom workshops |
| **prod** | Standard_D2s_v3 | 100GB | ❌ Disabled | Production workloads |

Override defaults by setting `vm_size` or `os_disk_size_gb` in your tfvars file.

## 🐳 Software Installation (Docker & Jenkins)

Docker and Jenkins are **installed by default** on all VMs. You can disable them individually if not needed.

### Default Behavior
```hcl
install_docker  = true   # Docker installed automatically
install_jenkins = true   # Jenkins installed as native service
```

### Access Jenkins
After the VM is provisioned, Jenkins will be available at:
```
http://<vm-public-ip>:8080
```

### Get Jenkins Initial Admin Password
```bash
# Get the Jenkins URL
terraform output jenkins_url

# SSH to the VM and get the initial admin password
ssh azureuser@<vm-ip> "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"

# Or get instructions from terraform
terraform output jenkins_admin_password
```

**Initial Admin Password**: Located at `/var/lib/jenkins/secrets/initialAdminPassword` on the VM  
**Setup**: Follow the Jenkins setup wizard on first access

### Disable Docker or Jenkins
If you don't need these tools, set them to `false` in your `terraform.tfvars`:
```hcl
install_docker  = false   # Skip Docker installation
install_jenkins = false   # Skip Jenkins installation
```

### Note
- Jenkins requires Docker, so if you disable Docker, Jenkins won't be installed
- Port 8080 is open by default in the network security group for Jenkins access
- Both services are configured to start automatically on boot

## 💰 Cost Estimates

### Development (Standard_B1s, 30GB)
```
VM (Standard_B1s):      $7.59/month
Storage (30GB HDD):     $1.54/month
Public IP (Standard):   $3.65/month
───────────────────────────────────
Total:                 ~$12.78/month
With 4-hour auto-shutdown: ~$4.26/month (67% savings!)
```

### Training (Standard_B2ms, 50GB)
```
VM (Standard_B2ms):    $60.74/month
Storage (50GB HDD):     $2.56/month
Public IP (Standard):   $3.65/month
───────────────────────────────────
Total:                 ~$66.95/month
With 4-hour auto-shutdown: ~$22.32/month (67% savings!)
```

### Production (Standard_D2s_v3, 100GB)
```
VM (Standard_D2s_v3):  $96.36/month
Storage (100GB HDD):    $5.12/month
Public IP (Standard):   $3.65/month
───────────────────────────────────
Total:                ~$105.13/month
```

## 🚀 Usage Examples

### Basic Deployment (Training Profile)

```hcl
# terraform.tfvars
project_name   = "myapp"
environment    = "training"
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ..."
```

```bash
terraform apply
```

### Custom Configuration

```hcl
# terraform.tfvars
project_name = "myapp"
environment  = "dev"
location     = "westus2"

# OS selection
os_distribution = "azure-linux"  # or "ubuntu"

# Override environment defaults
vm_size        = "Standard_B2s"
os_disk_size_gb = 40

# Security
allowed_ports = [22, 443, 8080]
allowed_cidrs = ["203.0.113.0/24"]  # Your corporate IP

# Auto-shutdown
enable_auto_shutdown = true
auto_shutdown_hours  = 6
auto_shutdown_timezone = "Eastern Standard Time"
```

### Production with Managed Identity

```hcl
# terraform.tfvars.prod
environment  = "prod"
vm_size      = "Standard_D2s_v3"

# Security
allowed_cidrs = ["10.0.0.0/8"]

# Enable managed identity for Azure resource access
enable_managed_identity = true

# Disable auto-shutdown for production
enable_auto_shutdown = false
```

## 🔑 SSH Key Setup

### Option 1: Use Existing Key

```bash
# Get your public key content
cat ~/.ssh/id_rsa.pub

# Or from Windows path
cat /mnt/c/Users/i/.ssh/id_rsa.pub

# Copy the entire output (starts with ssh-rsa or ssh-ed25519)
```

### Option 2: Generate New Key

```bash
# RSA (recommended for compatibility)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure_key

# Or Ed25519 (modern, more secure)
ssh-keygen -t ed25519 -f ~/.ssh/azure_key

# Get the public key
cat ~/.ssh/azure_key.pub
```

### Add to terraform.tfvars

```hcl
# Paste the FULL public key content (not the file path)
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... your-email@example.com"
```

**Important**: Azure needs the actual key content, not a file path!

## 🔌 Connect to Your VM

After deployment:

```bash
# Get SSH command from output
terraform output ssh_command

# Or manually
ssh azureuser@$(terraform output -raw vm_public_ip)
```

## 🛡️ Security Best Practices

1. **Restrict CIDR blocks** in production:
   ```hcl
   allowed_cidrs = ["10.0.0.0/8"]  # Corporate network only
   ```

2. **Use Azure Bastion** instead of public IP:
   ```hcl
   enable_public_ip = false
   # Deploy Azure Bastion in the VNet
   ```

3. **Enable managed identity** for Azure resource access:
   ```hcl
   enable_managed_identity = true
   ```

4. **Monitor costs** with Azure Cost Management and set budget alerts

## 🧹 Cleanup

```bash
# Destroy everything
terraform destroy

# Or with specific profile
terraform destroy -var-file=terraform.tfvars.training
```

**Important**: Azure VMs continue to incur compute costs even when stopped. Use `terraform destroy` or Azure CLI to deallocate:

```bash
az vm deallocate --resource-group rg-quickvm-training --name quickvm-vm
```

## 📝 Variables Reference

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `project_name` | Project identifier | `"quickvm"` | No |
| `environment` | Environment profile | `"training"` | No |
| `location` | Azure region | `"eastus"` | No |
| `os_distribution` | OS choice (ubuntu, azure-linux) | `"ubuntu"` | No |
| `vm_size` | Override environment default | `null` | No |
| `os_disk_size_gb` | Override environment default (GB) | `null` | No |
| `allowed_ports` | Inbound TCP ports | `[22, 80, 8080]` | No |
| `allowed_cidrs` | Allowed CIDR blocks | `["0.0.0.0/0"]` | No |
| `admin_username` | SSH username | `"azureuser"` | No |
| `ssh_public_key` | SSH public key content | - | **Yes** |
| `enable_public_ip` | Allocate public IP | `true` | No |
| `enable_auto_shutdown` | 4-hour auto-shutdown | `true` | No |

See [variables.tf](./variables.tf) for complete list.

## 🎓 Learn More

- [Module Documentation](../../../modules/azure/virtual-machine/README.md)
- [Cost Guide](../../../modules/azure/virtual-machine/COST.md)
- [Beginner's Guide](../../../docs/BEGINNER_GUIDE.md)
- [Azure Setup Guide](../../../docs/azure-setup-guide.md)

## 🐛 Troubleshooting

### "InvalidAuthenticationTokenTenant"
Login to Azure CLI:
```bash
az login
az account show
```

### "The subscription is not registered to use namespace"
Register required providers:
```bash
az provider register --namespace Microsoft.Compute
az provider register --namespace Microsoft.Network
```

### Connection Refused
Wait 2-3 minutes for VM to boot and cloud-init to complete.

### "SSH key validation failed"
Ensure your public key starts with `ssh-rsa`, `ssh-ed25519`, or `ecdsa-`:
```bash
cat ~/.ssh/id_rsa.pub | head -c 50
```

### Auto-Shutdown Not Triggering
The shutdown schedule uses "current time + hours". Check the schedule in Azure Portal:
```bash
az resource show --ids $(terraform output -raw vm_id)/schedules/shutdown-computevm-*
```

---

**Cost-Conscious Deployment** | **Sandbox-Safe Defaults** | **Production-Ready**
