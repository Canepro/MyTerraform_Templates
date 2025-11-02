# GCP Compute Engine Quick Deploy

Deploy a ready-to-use Ubuntu Linux VM in Google Cloud in under 3 minutes with SSH access configured.

## 🚀 Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.5.0
- [Google Cloud SDK](https://cloud.google.com/sdk) installed
- GCP account with billing enabled
- SSH key pair

### Step 1: Setup GCP Project

```bash
# Login to GCP
gcloud auth login

# Set default project
gcloud config set project YOUR_PROJECT_ID

# Enable required APIs
gcloud services enable compute.googleapis.com
```

### Step 2: Generate SSH Key (if you don't have one)

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
# Save to ~/.ssh/id_rsa (default location)
```

Get your public key:
```bash
# Linux/Mac
cat ~/.ssh/id_rsa.pub

# Windows (PowerShell)
Get-Content ~/.ssh/id_rsa.pub
```

### Step 3: Configure Variables

```bash
cd stacks/gcp/vm
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set:
```hcl
project_id   = "your-gcp-project-id"
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ... your_key_here"
```

### Step 4: Deploy

```bash
terraform init
terraform plan
terraform apply
```

**That's it!** Your VM is ready in 2-3 minutes. You'll get output like:

```
ssh ubuntu@34.123.45.67
```

## 📋 What Gets Created

- ✅ VPC Network (custom mode)
- ✅ Subnet (10.0.1.0/24)
- ✅ Firewall Rule (SSH port 22 open)
- ✅ Firewall Rule (ICMP for ping)
- ✅ Ubuntu 22.04 LTS VM (e2-micro)
- ✅ Public IP (ephemeral)

## 💰 Cost

- **e2-micro**: FREE (1 instance/month with $300 free credit)
- **pd-standard 20GB**: ~$1.00/month
- **Networking**: FREE
- **Total**: ~$1/month (within free tier)

**Free tier includes**:
- 1 f1-micro or e2-micro instance per month (30GB disk)
- $300 credit valid for 90 days

**After free credit**:
- e2-micro: ~$6/month
- pd-standard 20GB: ~$1/month
- **Total**: ~$7/month

## 🔧 Configuration Options

See [terraform.tfvars.example](terraform.tfvars.example) for all available options:

- `project_id`: GCP Project ID (REQUIRED)
- `project_name`: Name prefix for all resources
- `environment`: Environment tag
- `region`: GCP region (us-central1 is cheapest)
- `zone`: GCP zone
- `machine_type`: VM instance size
- `ssh_user`: SSH username (ubuntu for Ubuntu)
- `boot_disk_type`: Storage type (pd-standard is cheapest)
- `boot_disk_size`: Disk size in GB

## 🖥️ Connect to Your VM

After deployment:

```bash
# Use the output command
terraform output ssh_command

# Or manually
ssh ubuntu@YOUR_PUBLIC_IP

# Get the IP
terraform output vm_public_ip
```

**Default username**: `ubuntu` (for Ubuntu images)

## 🧹 Destroy Everything

When you're done:

```bash
terraform destroy
```

This removes all created resources and stops all billing.

## 📊 VM Details

| Property | Value |
|----------|-------|
| **OS** | Ubuntu 22.04 LTS |
| **Size** | e2-micro (2 vCPU, 1GB RAM) |
| **Disk** | 20GB pd-standard |
| **Network** | Public IP + VPC |
| **SSH** | Port 22 open to the world |

## 🔍 Troubleshooting

### "Project not found"
Make sure your `project_id` in `terraform.tfvars` is correct:
```bash
gcloud projects list
```

### "API not enabled"
Enable the Compute Engine API:
```bash
gcloud services enable compute.googleapis.com
```

### "Permission denied (publickey)"
Make sure you're using the correct SSH username:
- Ubuntu: `ubuntu`
- Debian: `debian`
- RHEL: `rhel`
- CentOS: `centos`
- Debian 9+: `user`

### "Connection refused"
Wait 1-2 minutes for the VM to fully boot and run startup scripts.

### Authentication Error
Authenticate with your GCP account:
```bash
gcloud auth application-default login
```

## 🎯 Use Cases

- Development environment
- Testing applications
- Learning GCP infrastructure
- Temporary compute needs
- CI/CD build agents
- Personal cloud services

## 🔐 Security Best Practices

1. **Use strong SSH keys**: `ssh-keygen -t rsa -b 4096`
2. **Restrict SSH access**: Consider limiting source ranges in firewall rules
3. **Use IAM service accounts**: For production, use service accounts
4. **Enable OS Login**: More secure SSH key management
5. **Use HTTPS**: Enable HTTPS-only communication

## 📚 Next Steps

- Add a load balancer for high availability
- Deploy across multiple zones
- Configure Cloud Monitoring
- Set up Cloud Logging
- Use Cloud Storage buckets
- Deploy to Kubernetes Engine

## 💡 Tips

- **Free tier**: e2-micro is free for 1 instance/month ($300 credit)
- **Regions**: us-central1 is typically cheapest
- **Preemptible instances**: Save up to 80% with preemptible VMs
- **Always destroy**: Run `terraform destroy` when done
- **Monitor costs**: Set up GCP billing alerts

## 🌍 Multi-Region

Deploy to different regions by changing `region` in `terraform.tfvars`:
- `us-central1` (Iowa) - Cheapest
- `us-east1` (S. Carolina) - Good for US East Coast
- `europe-west1` (Belgium) - Good for Europe
- `asia-northeast1` (Tokyo) - Good for Asia

## 🔧 Advanced Options

### Use Startup Script

Add initialization commands in `terraform.tfvars`:

```hcl
startup_script = <<-EOT
  #!/bin/bash
  apt-get update
  apt-get install -y nginx docker.io
  systemctl start nginx
EOT
```

### Use Different Machine Types

- `e2-micro`: 2 vCPU, 1GB RAM - FREE (free tier)
- `e2-small`: 2 vCPU, 2GB RAM - ~$12/month
- `e2-medium`: 2 vCPU, 4GB RAM - ~$24/month
- `n1-standard-1`: 1 vCPU, 3.75GB RAM - ~$25/month

### Different Disk Types

- `pd-standard`: Standard persistent disk - Cheapest
- `pd-balanced`: Balanced persistent disk - Better performance
- `pd-ssd`: SSD persistent disk - Best performance

## 🤝 Contributing

Found a bug or have a suggestion? [Open an issue](https://github.com/Canepro/MyTerraform_Templates/issues) or submit a PR.

## 📄 License

MIT License - Copyright (c) 2025
