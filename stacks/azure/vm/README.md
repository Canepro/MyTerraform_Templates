# Azure VM Quick Deploy

Deploy a ready-to-use Ubuntu Linux VM in Azure in under 3 minutes with SSH access configured.

## 🚀 Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.5.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Azure account with appropriate permissions
- SSH key pair

### Step 1: Generate SSH Key (if you don't have one)

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

### Step 2: Login to Azure

```bash
az login
```

### Step 3: Configure Variables

```bash
cd stacks/azure/vm
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set your SSH public key:
```hcl
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
ssh azureuser@52.168.123.45
```

## 📋 What Gets Created

- ✅ Resource Group
- ✅ Virtual Network (10.0.0.0/16)
- ✅ Subnet (10.0.1.0/24)
- ✅ Network Security Group (SSH port 22 open)
- ✅ Public IP (static)
- ✅ Network Interface
- ✅ Ubuntu 22.04 LTS VM (Standard_B1s)
- ✅ Optional: Auto-shutdown schedule

## 💰 Cost

- **Standard_B1s VM**: ~$9.50/month (~$0.013/hour)
- **Standard_LRS Disk**: ~$2.30/month for 30GB
- **Networking**: FREE
- **Total**: ~$12/month

**Money-saving tip**: Enable auto-shutdown in `terraform.tfvars`:
```hcl
enable_auto_shutdown = true
auto_shutdown_time   = "1900"  # Auto-shutdown at 7 PM daily
```

## 🔧 Configuration Options

See [terraform.tfvars.example](terraform.tfvars.example) for all available options:

- `project_name`: Name prefix for all resources
- `environment`: Environment tag (dev/test/prod)
- `location`: Azure region
- `vm_size`: VM instance size
- `admin_username`: SSH username
- `os_disk_type`: Storage type (Standard_LRS is cheapest)
- `enable_auto_shutdown`: Enable cost-saving auto-shutdown

## 🖥️ Connect to Your VM

After deployment, you'll see output with the SSH command:

```bash
ssh azureuser@YOUR_PUBLIC_IP
```

Or use:
```bash
# Get the IP and SSH command
terraform output ssh_command

# Just get the IP
terraform output vm_public_ip
```

## 🧹 Destroy Everything

When you're done:

```bash
terraform destroy
```

This removes all created resources and stops all billing.

## 📊 VM Details

| Property | Value |
|----------|-------|
| **OS** | Ubuntu 22.04 LTS (Gen2) |
| **Size** | Standard_B1s (1 vCPU, 1GB RAM) |
| **Disk** | 30GB Standard HDD |
| **Network** | Public IP + VNet |
| **SSH** | Port 22 open to the world |

## 🔍 Troubleshooting

### "Could not authenticate using ssh-agent"
Make sure your SSH private key is in the default location:
```bash
eval $(ssh-agent)
ssh-add ~/.ssh/id_rsa
```

### "Connection refused"
Wait a minute or two for the VM to fully boot, then try again.

### "Permission denied (publickey)"
Double-check your SSH public key in `terraform.tfvars` is correct.

### Need to see logs?
```bash
# Azure Portal
az vm list --output table

# Get boot diagnostics
az vm boot-diagnostics get-boot-log --name quickvm-vm --resource-group rg-quickvm-dev
```

## 🎯 Use Cases

- Development environment
- Testing new software
- Learning cloud infrastructure
- Temporary compute needs
- CI/CD build agents
- Personal cloud services

## 🔐 Security Best Practices

1. **Use strong SSH keys**: `ssh-keygen -t rsa -b 4096`
2. **Limit SSH access**: Consider restricting `source_address_prefix` in `main.tf`
3. **Enable auto-shutdown**: Prevents accidental ongoing costs
4. **Use Key Vault**: For production, store secrets in Azure Key Vault
5. **Enable just-in-time access**: Use Azure Security Center features

## 📚 Next Steps

- Add a load balancer for high availability
- Deploy multiple VMs in an availability set
- Use managed disks for better performance
- Configure application insights for monitoring
- Set up automated backups

## 💡 Tips

- **Test locally first**: Use `terraform plan` to preview changes
- **Always destroy**: Run `terraform destroy` when done to avoid charges
- **Monitor costs**: Set up Azure cost alerts
- **Keep it simple**: This stack is designed for quick deployments
- **Scale up**: Edit `vm_size` for more CPU/RAM if needed

## 🤝 Contributing

Found a bug or have a suggestion? [Open an issue](https://github.com/Canepro/MyTerraform_Templates/issues) or submit a PR.

## 📄 License

MIT License - Copyright (c) 2025
