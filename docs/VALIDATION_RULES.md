# Validation Rules Reference

This document explains all validation rules enforced by the modules to prevent common configuration errors.

---

## 🔤 Naming Conventions

### Project Name

**Rule**: `^[a-z0-9-]{1,30}$`

**Valid**:
- ✅ `quickvm`
- ✅ `devops-training`
- ✅ `my-sandbox-01`
- ✅ `prod-app`

**Invalid**:
- ❌ `dev_ops_training` (underscores not allowed)
- ❌ `MyProject` (uppercase not allowed)
- ❌ `project.name` (dots not allowed)
- ❌ `this-is-a-very-long-project-name-that-exceeds-thirty-characters` (too long)

**Why**: AWS/Azure resource naming restrictions, consistency across clouds

---

### Environment

**Rule**: Must be one of: `dev`, `training`, `prod`

**Valid**:
- ✅ `dev`
- ✅ `training`
- ✅ `prod`

**Invalid**:
- ❌ `development`
- ❌ `staging`
- ❌ `test`
- ❌ `sandbox`

**Why**: Tied to environment profiles that auto-select instance sizing

---

## 💾 Storage Validation

### Root Volume Size (AWS)

**Rule**: `30 <= size <= 16384` GB

**Valid**:
- ✅ `30` (minimum, Amazon Linux 2023 requirement)
- ✅ `50`
- ✅ `100`
- ✅ `16384` (maximum)

**Invalid**:
- ❌ `20` (too small for Amazon Linux 2023)
- ❌ `20000` (exceeds AWS EBS limit)

**Why**: Amazon Linux 2023 requires minimum 30GB, AWS EBS max is 16TB

---

### OS Disk Size (Azure)

**Rule**: `30 <= size <= 2048` GB

**Valid**:
- ✅ `30` (minimum)
- ✅ `50`
- ✅ `100`
- ✅ `2048` (maximum for Standard_LRS)

**Invalid**:
- ❌ `20` (too small)
- ❌ `4096` (exceeds Standard_LRS limit)

**Why**: Ubuntu 22.04 minimum requirements, Azure disk size limits

---

## 🌐 Networking Validation

### Allowed Ports

**Rule**: `1 <= port <= 65535`

**Valid**:
- ✅ `[22, 80, 443, 8080]`
- ✅ `[22]`
- ✅ `[3000, 3001, 3002]`

**Invalid**:
- ❌ `[0]` (port 0 is reserved)
- ❌ `[80000]` (exceeds max port number)
- ❌ `[-1]` (negative ports invalid)
- ❌ `[22, 80, 442, 8080]` (typo: 442 should be 443)

**Why**: TCP/IP port range is 1-65535

---

### CIDR Blocks

**Rule**: Valid CIDR notation

**Valid**:
- ✅ `["0.0.0.0/0"]` (all IPs, use with caution)
- ✅ `["203.0.113.0/24"]` (single /24 network)
- ✅ `["10.0.0.0/8", "172.16.0.0/12"]` (multiple networks)

**Invalid**:
- ❌ `["203.0.113.0"]` (missing /prefix)
- ❌ `["203.0.113.0/33"]` (invalid prefix, max is /32)
- ❌ `["999.999.999.999/24"]` (invalid IP)

**Why**: Standard CIDR notation for IP ranges

---

## 🔑 Authentication Validation

### AWS Key Name

**Rule**: Must exist in AWS account (not validated by Terraform, runtime check)

**Valid**:
- ✅ `"my-aws-key"` (if exists in AWS)
- ✅ `"prod-key-2024"`

**Invalid**:
- ❌ `"nonexistent-key"` (will fail at apply time)
- ❌ `""` (empty string)

**Why**: AWS requires key pair to exist before instance creation

---

### Azure SSH Public Key

**Rule**: Must start with `ssh-rsa`, `ssh-ed25519`, or `ecdsa-`

**Valid**:
- ✅ `"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ..."`
- ✅ `"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA..."`
- ✅ `"ecdsa-sha2-nistp256 AAAAE2VjZHNh..."`

**Invalid**:
- ❌ `"AAAAB3NzaC1yc2EAAAADAQABAAACAQ..."` (missing key type prefix)
- ❌ `"my-key-name"` (not a public key)
- ❌ `"~/.ssh/id_rsa.pub"` (file path, not key content)

**Why**: Azure requires the actual public key content, not a file path

---

### Azure Admin Username

**Rule**: `^[a-z][a-z0-9-]{0,63}$`

**Valid**:
- ✅ `"azureuser"` (default)
- ✅ `"admin"
- ✅ `"myuser123"`

**Invalid**:
- ❌ `"Admin"` (must start with lowercase)
- ❌ `"123user"` (must start with letter)
- ❌ `"user_name"` (underscores not allowed)

**Why**: Azure Linux VM username restrictions

---

## ⏱️ Auto-Shutdown Validation

### Shutdown Hours

**Rule**: `1 <= hours <= 24`

**Valid**:
- ✅ `4` (default, 4 hours)
- ✅ `1` (minimum)
- ✅ `8`
- ✅ `24` (maximum)

**Invalid**:
- ❌ `0` (must be at least 1 hour)
- ❌ `48` (exceeds 24 hours)
- ❌ `-1` (negative values invalid)

**Why**: Practical limits for sandbox environments

---

## 🏷️ Operating System Validation

### AWS OS Distribution

**Rule**: Must be `amazon-linux` or `ubuntu`

**Valid**:
- ✅ `"amazon-linux"` (default)
- ✅ `"ubuntu"`

**Invalid**:
- ❌ `"centos"`
- ❌ `"rhel"`
- ❌ `"windows"`

**Why**: Only these two are configured in the module

---

### Azure OS Distribution

**Rule**: Must be `ubuntu` or `azure-linux`

**Valid**:
- ✅ `"ubuntu"` (default)
- ✅ `"azure-linux"` (CBL-Mariner)

**Invalid**:
- ❌ `"amazon-linux"` (not available on Azure)
- ❌ `"centos"`
- ❌ `"windows"`

**Why**: Only these two are configured in the module

---

## 🔧 Common Validation Errors & Fixes

### Error: Project name validation failed

```
Error: Invalid value for variable
│ Project name must be 1-30 characters, lowercase alphanumeric and hyphens only
```

**Fix**: Use hyphens instead of underscores
```hcl
# ❌ Wrong
project_name = "dev_ops_training"

# ✅ Correct
project_name = "devops-training"
```

---

### Error: Root volume size too small

```
Error: Invalid value for variable
│ Root volume size must be between 30 and 16384 GB
```

**Fix**: Increase to at least 30GB
```hcl
# ❌ Wrong
root_volume_size = 20

# ✅ Correct
root_volume_size = 30
```

---

### Error: Invalid port number

```
Error: Invalid value for variable
│ Allowed ports must be between 1 and 65535
```

**Fix**: Check for typos (common: 442 instead of 443)
```hcl
# ❌ Wrong
allowed_ports = [22, 80, 442, 8080]

# ✅ Correct
allowed_ports = [22, 80, 443, 8080]
```

---

### Error: SSH key validation failed (Azure)

```
Error: Invalid value for variable
│ Must be a valid SSH public key (ssh-rsa, ssh-ed25519, or ecdsa)
```

**Fix**: Provide the key content, not the file path
```hcl
# ❌ Wrong
ssh_public_key = "~/.ssh/id_rsa.pub"

# ✅ Correct
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ..."
```

Get your public key:
```bash
cat ~/.ssh/id_rsa.pub
```

---

### Warning: Undeclared variables

```
Warning: Value for undeclared variable
│ The root module does not declare a variable named "vpc_cidr"
```

**Fix**: Remove unused variables from your tfvars file
```hcl
# ❌ Remove these (not needed with refactored stack)
vpc_cidr    = "10.0.0.0/16"
subnet_cidr = "10.0.1.0/24"
key_path    = "~/.ssh/my-key.pem"

# ✅ Keep only these
vpc_id    = null  # Uses default VPC
subnet_id = null  # Uses default subnet
key_name  = "my-aws-key"  # Just the key name
```

---

## 📋 Pre-Flight Checklist

Before running `terraform plan`:

- [ ] `project_name` uses only lowercase, numbers, and hyphens
- [ ] `environment` is one of: dev, training, prod
- [ ] `allowed_ports` are all between 1-65535
- [ ] `root_volume_size` / `os_disk_size_gb` >= 30
- [ ] AWS: `key_name` matches an existing key pair
- [ ] Azure: `ssh_public_key` contains the full public key content
- [ ] No underscores in any names
- [ ] CIDR blocks are valid (e.g., `203.0.113.0/24`)

---

## 🔍 Validation Testing

Test your configuration before applying:

```bash
# Validate syntax and configuration
terraform validate

# Check for validation errors
terraform plan -var-file=terraform.tfvars.training

# Look for these sections in output:
# - "Error: Invalid value for variable" (fix required)
# - "Warning: Value for undeclared variable" (cleanup recommended)
```

---

**Validation Rules** | **Error Prevention** | **Configuration Safety**

