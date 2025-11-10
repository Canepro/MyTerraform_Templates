# SSH Key Management Guide

Complete guide for managing SSH keys across AWS and Azure deployments.

---

## 📋 Quick Reference

### Your Current Setup

**AWS Key Pair:**
- **Private Key Location**: `C:\Users\i\dev\aws_key.pem`
- **AWS Key Pair Name**: `aws_key`
- **Usage**: Set `key_name = "aws_key"` in terraform.tfvars

**Connect to AWS EC2:**
```bash
# WSL/Git Bash
ssh -i /mnt/c/Users/i/dev/aws_key.pem ubuntu@<PUBLIC_IP>

# Or copy to WSL home
cp /mnt/c/Users/i/dev/aws_key.pem ~/.ssh/
chmod 400 ~/.ssh/aws_key.pem
ssh -i ~/.ssh/aws_key.pem ubuntu@<PUBLIC_IP>
```

---

## 🔐 AWS SSH Keys

### Understanding AWS Key Pairs

AWS manages the **public key** on their side. You only need:
1. The **key pair name** (e.g., `aws_key`)
2. The **private key file** (e.g., `aws_key.pem`)

### Scenario 1: You Already Have a .pem File

**Your Situation**: You have `C:\Users\i\dev\aws_key.pem`

#### Option A: Import to AWS (Recommended)

```bash
# Extract public key from private key
ssh-keygen -y -f /mnt/c/Users/i/dev/aws_key.pem > ~/.ssh/aws_key.pub

# Import to AWS
aws ec2 import-key-pair \
  --key-name aws_key \
  --public-key-material fileb://~/.ssh/aws_key.pub

# Verify
aws ec2 describe-key-pairs --key-name aws_key
```

#### Option B: Use Existing AWS Key Pair

If the key was originally created in AWS:

```bash
# List your existing keys
aws ec2 describe-key-pairs --query 'KeyPairs[*].KeyName' --output table

# Use the matching key name in terraform.tfvars
key_name = "aws_key"
```

### Scenario 2: Create New Key Pair in AWS

```bash
# Create new key pair
aws ec2 create-key-pair \
  --key-name my-new-key \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/my-new-key.pem

# Set permissions
chmod 400 ~/.ssh/my-new-key.pem

# Use in terraform.tfvars
key_name = "my-new-key"
```

### Scenario 3: Create Key Pair via AWS Console

1. Go to **EC2 Dashboard** → **Key Pairs**
2. Click **Create key pair**
3. Name: `my-key`
4. Key pair type: **RSA**
5. Private key format: **.pem**
6. Click **Create** (downloads `my-key.pem`)
7. Move to safe location:
   ```bash
   mv ~/Downloads/my-key.pem C:\Users\i\dev\
   # Or in WSL
   mv /mnt/c/Users/i/Downloads/my-key.pem ~/.ssh/
   chmod 400 ~/.ssh/my-key.pem
   ```

### AWS Key Management Commands

```bash
# List all key pairs
aws ec2 describe-key-pairs

# List key pair names only
aws ec2 describe-key-pairs --query 'KeyPairs[*].KeyName' --output table

# Get details of specific key
aws ec2 describe-key-pairs --key-name aws_key

# Delete a key pair (careful!)
aws ec2 delete-key-pair --key-name old-key

# Import existing public key
aws ec2 import-key-pair \
  --key-name imported-key \
  --public-key-material fileb://~/.ssh/id_rsa.pub
```

---

## 🔐 Azure SSH Keys

### Understanding Azure SSH Keys

Azure requires the **full public key content** in your Terraform configuration.

### Scenario 1: Generate New SSH Key

```bash
# Generate RSA key (recommended)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/azure_key

# Or generate Ed25519 key (modern, more secure)
ssh-keygen -t ed25519 -f ~/.ssh/azure_key

# Files created:
# - ~/.ssh/azure_key (private key)
# - ~/.ssh/azure_key.pub (public key)
```

### Scenario 2: Use Existing SSH Key

```bash
# Get your public key content
cat ~/.ssh/id_rsa.pub

# Or from Windows path
cat /mnt/c/Users/i/.ssh/id_rsa.pub

# Copy the entire output (starts with ssh-rsa or ssh-ed25519)
```

### Add to Terraform

```hcl
# terraform.tfvars
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC7... your-email@example.com"
```

### Azure Key Management Commands

```bash
# List VMs and their admin users
az vm list --output table

# Show VM details including SSH key
az vm show \
  --resource-group rg-quickvm-dev \
  --name quickvm-vm \
  --query osProfile.linuxConfiguration.ssh.publicKeys

# Reset SSH key on existing VM
az vm user update \
  --resource-group rg-quickvm-dev \
  --name quickvm-vm \
  --username azureuser \
  --ssh-key-value "$(cat ~/.ssh/new_key.pub)"
```

---

## 🔄 Converting Between Key Formats

### Extract Public Key from Private Key

```bash
# From .pem file
ssh-keygen -y -f ~/.ssh/aws_key.pem > ~/.ssh/aws_key.pub

# From standard private key
ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub
```

### Convert PuTTY Key to OpenSSH

```bash
# Install puttygen (if needed)
sudo apt-get install putty-tools

# Convert .ppk to OpenSSH format
puttygen aws_key.ppk -O private-openssh -o aws_key.pem

# Extract public key
puttygen aws_key.ppk -O public-openssh -o aws_key.pub
```

### Convert OpenSSH to PuTTY

```bash
# Convert private key
puttygen aws_key.pem -o aws_key.ppk -O private

# Public key is automatically included
```

---

## 📁 Recommended Key Organization

### Directory Structure

```
C:\Users\i\dev\
├── aws_key.pem              # Your current AWS key
├── azure_key                # Azure private key
└── azure_key.pub            # Azure public key

# Or in WSL
~/.ssh/
├── aws_key.pem              # AWS private key
├── aws_key.pub              # AWS public key (extracted)
├── azure_key                # Azure private key
├── azure_key.pub            # Azure public key
├── config                   # SSH config file
└── known_hosts              # Trusted hosts
```

### SSH Config File

Create `~/.ssh/config` for easy connections:

```bash
# AWS Training VM
Host aws-training
    HostName <PUBLIC_IP>
    User ubuntu
    IdentityFile ~/.ssh/aws_key.pem
    StrictHostKeyChecking no

# Azure Training VM
Host azure-training
    HostName <PUBLIC_IP>
    User azureuser
    IdentityFile ~/.ssh/azure_key
    StrictHostKeyChecking no
```

Then connect with:
```bash
ssh aws-training
ssh azure-training
```

---

## 🔒 Security Best Practices

### File Permissions

```bash
# Private keys must be 400 (read-only by owner)
chmod 400 ~/.ssh/aws_key.pem
chmod 400 ~/.ssh/azure_key

# Public keys can be 644
chmod 644 ~/.ssh/aws_key.pub
chmod 644 ~/.ssh/azure_key.pub

# SSH directory should be 700
chmod 700 ~/.ssh
```

### Key Rotation

```bash
# Generate new key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/aws_key_new.pem

# Import to AWS
aws ec2 import-key-pair \
  --key-name aws_key_new \
  --public-key-material fileb://~/.ssh/aws_key_new.pub

# Update terraform.tfvars
key_name = "aws_key_new"

# Deploy with new key
terraform apply

# After verification, delete old key
aws ec2 delete-key-pair --key-name aws_key
```

### Backup Keys

```bash
# Backup to encrypted location
cp ~/.ssh/aws_key.pem /mnt/c/Users/i/Backup/keys/
cp ~/.ssh/azure_key /mnt/c/Users/i/Backup/keys/

# Or use password manager (1Password, LastPass, etc.)
```

---

## 🐛 Troubleshooting

### "Permission denied (publickey)"

```bash
# Check key permissions
ls -la ~/.ssh/aws_key.pem
# Should show: -r-------- (400)

# Fix permissions
chmod 400 ~/.ssh/aws_key.pem

# Verify key fingerprint
ssh-keygen -lf ~/.ssh/aws_key.pem

# Test connection with verbose output
ssh -v -i ~/.ssh/aws_key.pem ubuntu@<IP>
```

### "Invalid key pair"

```bash
# Verify key exists in AWS
aws ec2 describe-key-pairs --key-name aws_key

# Check key format
head -n 1 ~/.ssh/aws_key.pem
# Should show: -----BEGIN RSA PRIVATE KEY-----

# Re-import if needed
aws ec2 import-key-pair \
  --key-name aws_key \
  --public-key-material fileb://~/.ssh/aws_key.pub
```

### "Bad permissions" / "UNPROTECTED PRIVATE KEY FILE"

**Error Message:**
```
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@         WARNING: UNPROTECTED PRIVATE KEY FILE!          @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
Permissions 0777 for '/mnt/c/Users/i/dev/aws_key.pem' are too open.
```

**Solution: Copy to WSL and Fix Permissions** (Recommended)

```bash
# Copy key from Windows to WSL
cp /mnt/c/Users/i/dev/aws_key.pem ~/.ssh/

# Fix permissions (read-only by owner)
chmod 400 ~/.ssh/aws_key.pem

# Verify permissions are correct
ls -la ~/.ssh/aws_key.pem
# Should show: -r-------- (400)

# Now you can use it
ssh-keygen -y -f ~/.ssh/aws_key.pem > ~/.ssh/aws_key.pub
```

**Alternative: Fix Windows Permissions**

```powershell
# In PowerShell (not WSL)
icacls C:\Users\i\dev\aws_key.pem /inheritance:r
icacls C:\Users\i\dev\aws_key.pem /grant:r "%USERNAME%:R"
```

**Why This Happens**: Windows filesystem permissions (0777) don't translate to Linux. SSH requires private keys to be readable ONLY by the owner.

### Wrong Username

```bash
# AWS EC2 default usernames by OS:
# - Amazon Linux: ec2-user
# - Ubuntu: ubuntu
# - RHEL: ec2-user
# - Debian: admin

# Azure default username:
# - Linux: azureuser (or custom from terraform.tfvars)

# Check with:
ssh -i ~/.ssh/aws_key.pem ubuntu@<IP>  # AWS Ubuntu
ssh -i ~/.ssh/azure_key azureuser@<IP>  # Azure
```

---

## 📝 Documentation Template

Add this to your project README or keep in a notes file:

```markdown
## SSH Keys

### AWS
- **Key Name**: aws_key
- **Private Key**: C:\Users\i\dev\aws_key.pem
- **Region**: us-east-1
- **Default User**: ubuntu (Ubuntu) / ec2-user (Amazon Linux)
- **Connect**: `ssh -i /mnt/c/Users/i/dev/aws_key.pem ubuntu@<IP>`

### Azure
- **Private Key**: ~/.ssh/azure_key
- **Public Key**: ~/.ssh/azure_key.pub
- **Default User**: azureuser
- **Connect**: `ssh -i ~/.ssh/azure_key azureuser@<IP>`

### Quick Connect (after terraform apply)
```bash
# Get connection command from Terraform
terraform output ssh_command

# Or manually
terraform output -raw vm_public_ip
ssh -i ~/.ssh/aws_key.pem ubuntu@$(terraform output -raw vm_public_ip)
```
```

---

## ✅ Key Verification Checklist

### Check if Key is Already in WSL

```bash
# List keys in WSL SSH directory
ls -la ~/.ssh/

# Check if your key exists
ls -la ~/.ssh/aws_key.pem

# If it exists, verify permissions
ls -la ~/.ssh/aws_key.pem
# Should show: -r-------- (400)
```

### Check if Key is Already in AWS

```bash
# List all your AWS key pairs
aws ec2 describe-key-pairs --query 'KeyPairs[*].KeyName' --output table

# Check specific key
aws ec2 describe-key-pairs --key-name aws_key

# If found, you'll see:
# {
#     "KeyPairs": [
#         {
#             "KeyPairId": "key-07d22919101ed8639",
#             "KeyName": "aws_key",
#             "KeyFingerprint": "97:e1:5e:09:04:e8:99:ad:a6:90:82:6d:61:59:22:a2"
#         }
#     ]
# }
```

### Verify Key Fingerprint Match

```bash
# Get fingerprint from local key
ssh-keygen -lf ~/.ssh/aws_key.pem
# Output: 2048 SHA256:abc123... (RSA)

# Get fingerprint from AWS
aws ec2 describe-key-pairs --key-name aws_key --query 'KeyPairs[0].KeyFingerprint' --output text
# Output: 97:e1:5e:09:04:e8:99:ad:a6:90:82:6d:61:59:22:a2

# Note: AWS shows MD5 fingerprint, local shows SHA256 by default
# To compare, use MD5 format:
ssh-keygen -lf ~/.ssh/aws_key.pem -E md5
```

## 🚀 Quick Start Checklist

### First-Time Setup

- [ ] **Locate** your private key file: `C:\Users\i\dev\aws_key.pem`
- [ ] **Copy** to WSL: `cp /mnt/c/Users/i/dev/aws_key.pem ~/.ssh/`
- [ ] **Fix permissions**: `chmod 400 ~/.ssh/aws_key.pem`
- [ ] **Verify permissions**: `ls -la ~/.ssh/aws_key.pem` (should show `-r--------`)
- [ ] **Extract public key**: `ssh-keygen -y -f ~/.ssh/aws_key.pem > ~/.ssh/aws_key.pub`
- [ ] **Import to AWS**: `aws ec2 import-key-pair --key-name aws_key --public-key-material fileb://~/.ssh/aws_key.pub`
- [ ] **Verify import**: `aws ec2 describe-key-pairs --key-name aws_key`
- [ ] **Update terraform.tfvars**: `key_name = "aws_key"`
- [ ] **Test after deploy**: `ssh -i ~/.ssh/aws_key.pem ubuntu@<IP>`

### Quick Verification (Already Setup)

```bash
# One-liner to check everything
[ -f ~/.ssh/aws_key.pem ] && \
  echo "✅ Key exists in WSL" || \
  echo "❌ Key not found in WSL"

[ "$(stat -c %a ~/.ssh/aws_key.pem 2>/dev/null)" = "400" ] && \
  echo "✅ Permissions correct (400)" || \
  echo "❌ Fix permissions: chmod 400 ~/.ssh/aws_key.pem"

aws ec2 describe-key-pairs --key-name aws_key &>/dev/null && \
  echo "✅ Key imported to AWS" || \
  echo "❌ Import key to AWS"
```

---

## 📚 See Also

SSH key setup is also covered in these guides for quick reference:

- **[Beginner's Guide](./BEGINNER_GUIDE.md)** - Step-by-step SSH setup in deployment workflow
- **[Quick Reference](./QUICK_REFERENCE.md)** - Copy-paste commands for common scenarios
- **[AWS Stack README](../stacks/aws/vm/README.md)** - AWS-specific key setup options
- **[Azure Stack README](../stacks/azure/vm/README.md)** - Azure-specific key setup options

This document provides the comprehensive reference; the others provide quick-start snippets.

---

**Key Management** | **Security First** | **Cross-Platform Compatible**

