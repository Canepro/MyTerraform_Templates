# AWS EC2 VM Stack

Deploy a production-ready EC2 instance using the unified module interface with environment-driven defaults, auto-shutdown, and configurable security.

## 🎯 Quick Deploy

```bash
cd stacks/aws/vm

# Copy and edit configuration
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars and set your key_name

# Deploy with training profile
terraform init
terraform apply

# Or use a specific environment profile
terraform apply -var-file=terraform.tfvars.dev
terraform apply -var-file=terraform.tfvars.training
terraform apply -var-file=terraform.tfvars.prod
```

## 🏗️ What Gets Created

This stack uses the **ec2-instance module** which automatically provisions:

- ✅ **Default VPC** (or custom VPC if specified)
- ✅ **Security Group** with configurable ports (22, 80, 8080 by default)
- ✅ **EC2 Instance** with environment-specific sizing
- ✅ **Elastic IP** (optional, enabled by default)
- ✅ **Auto-shutdown helper** (4-hour default for sandbox safety)
- ✅ **Docker** (installed by default, can be disabled)
- ✅ **Jenkins** (installed by default via Docker, can be disabled)

## 📊 Environment Profiles

| Environment | Instance Type | Root Volume | Auto-Shutdown | Use Case |
|-------------|---------------|-------------|---------------|----------|
| **dev** | t3.micro | 30GB | ✅ 4 hours | Free-tier labs, quick tests |
| **training** | t3.medium | 50GB | ✅ 4 hours | Classroom workshops |
| **prod** | t3.large | 100GB | ❌ Disabled | Stable demo workloads |

Override defaults by setting `instance_type` or `root_volume_size` in your tfvars file.

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
ssh -i ~/.ssh/aws_key.pem ubuntu@<vm-ip> "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"

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
- Port 8080 is open by default in the security group for Jenkins access
- Both services are configured to start automatically on boot

## 💰 Cost Estimates

### Development (t3.micro, 30GB)
```
Instance (t3.micro):     $7.50/month  (FREE first 12 months)
Storage (30GB gp3):      $2.40/month
Elastic IP (attached):   FREE
───────────────────────────────────
Total:                  ~$9.90/month (~$2.40/month with free tier)
```

### Training (t3.medium, 50GB)
```
Instance (t3.medium):   $30.37/month
Storage (50GB gp3):      $4.00/month
Elastic IP (attached):   FREE
───────────────────────────────────
Total:                 ~$34.37/month
With 4-hour auto-shutdown: ~$11.46/month (67% savings!)
```

### Production (t3.large, 100GB)
```
Instance (t3.large):    $60.74/month
Storage (100GB gp3):     $8.00/month
Elastic IP (attached):   FREE
───────────────────────────────────
Total:                 ~$68.74/month
```

## 🚀 Usage Examples

### Basic Deployment (Training Profile)

```hcl
# terraform.tfvars
project_name = "myapp"
environment  = "training"
key_name     = "my-aws-key"
```

```bash
terraform apply
```

### Custom Configuration

```hcl
# terraform.tfvars
project_name = "myapp"
environment  = "dev"
region       = "us-west-2"

# OS selection
os_distribution = "ubuntu"  # or "amazon-linux"

# Override environment defaults
instance_type    = "t3.small"
root_volume_size = 40

# Security
allowed_ports = [22, 443, 8080]
allowed_cidrs = ["203.0.113.0/24"]  # Your corporate IP

# Auto-shutdown
enable_auto_shutdown = true
auto_shutdown_hours  = 6
```

### Using Existing VPC

```hcl
# terraform.tfvars
vpc_id    = "vpc-1234567890abcdef0"
subnet_id = "subnet-1234567890abcdef0"
```

## 🔑 SSH Key Setup

### Option 1: Import Existing Key (if you have a .pem file)

```bash
# Extract public key from your private key
ssh-keygen -y -f /mnt/c/Users/i/dev/aws_key.pem > ~/.ssh/aws_key.pub

# Import to AWS
aws ec2 import-key-pair \
  --key-name aws_key \
  --public-key-material fileb://~/.ssh/aws_key.pub

# Verify import
aws ec2 describe-key-pairs --key-name aws_key

# Use in terraform.tfvars: key_name = "aws_key"
```

### Option 2: Create New Key via AWS CLI

```bash
# Create new key pair
aws ec2 create-key-pair \
  --key-name my-aws-key \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/my-aws-key.pem

# Set permissions
chmod 400 ~/.ssh/my-aws-key.pem

# Use in terraform.tfvars: key_name = "my-aws-key"
```

### Option 3: AWS Console

1. Go to **EC2 Dashboard** → **Key Pairs** → **Create Key Pair**
2. Download the `.pem` file
3. Move to safe location: `mv ~/Downloads/my-key.pem ~/.ssh/`
4. Set permissions: `chmod 400 ~/.ssh/my-key.pem`
5. Set `key_name = "my-key"` in terraform.tfvars

### List Existing Keys

```bash
aws ec2 describe-key-pairs --query 'KeyPairs[*].KeyName' --output table
```

## 🔌 Connect to Your VM

After deployment:

```bash
# Get SSH command from output
terraform output ssh_command

# Or manually
ssh ec2-user@$(terraform output -raw vm_public_ip)

# For Ubuntu
ssh ubuntu@$(terraform output -raw vm_public_ip)
```

## 🛡️ Security Best Practices

1. **Restrict CIDR blocks** in production:
   ```hcl
   allowed_cidrs = ["10.0.0.0/8"]  # Corporate network only
   ```

2. **Use Systems Manager** instead of SSH:
   ```hcl
   iam_instance_profile = "AmazonSSMManagedInstanceCore"
   allowed_ports        = [80, 443]  # Remove SSH
   ```

3. **Enable termination protection** for prod:
   ```hcl
   enable_termination_protection = true
   ```

4. **Monitor costs** with AWS Budgets and Cost Explorer

## 🧹 Cleanup

```bash
# Destroy everything
terraform destroy

# Or with specific profile
terraform destroy -var-file=terraform.tfvars.training
```

## 📝 Variables Reference

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `project_name` | Project identifier | `"quickvm"` | No |
| `environment` | Environment profile | `"training"` | No |
| `region` | AWS region | `"us-east-1"` | No |
| `os_distribution` | OS choice (amazon-linux, ubuntu) | `"amazon-linux"` | No |
| `instance_type` | Override environment default | `null` | No |
| `root_volume_size` | Override environment default (GB) | `null` | No |
| `allowed_ports` | Inbound TCP ports | `[22, 80, 8080]` | No |
| `allowed_cidrs` | Allowed CIDR blocks | `["0.0.0.0/0"]` | No |
| `key_name` | AWS key pair name | `null` | **Yes** |
| `enable_eip` | Allocate Elastic IP | `true` | No |
| `enable_auto_shutdown` | 4-hour auto-shutdown | `true` | No |

See [variables.tf](./variables.tf) for complete list.

## 🎓 Learn More

- [Module Documentation](../../../modules/aws/ec2-instance/README.md)
- [Cost Guide](../../../modules/aws/ec2-instance/COST.md)
- [Beginner's Guide](../../../docs/BEGINNER_GUIDE.md)
- [AWS Setup Guide](../../../docs/aws-setup-guide.md)

## 🐛 Troubleshooting

### "InvalidKeyPair.NotFound"
The key pair must exist in the same region. Check with:
```bash
aws ec2 describe-key-pairs --region us-east-1
```

### "UnauthorizedOperation"
Your AWS credentials need EC2 permissions. Verify with:
```bash
aws sts get-caller-identity
```

### Connection Refused
Wait 1-2 minutes for instance to boot, then retry SSH.

### Auto-Shutdown Not Working
The shutdown helper runs in user-data. Check logs:
```bash
ssh ec2-user@<ip>
sudo journalctl -u cloud-final
```

---

**Cost-Conscious Deployment** | **Sandbox-Safe Defaults** | **Production-Ready**
