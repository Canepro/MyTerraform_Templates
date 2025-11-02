# Quick-Deploy Stacks

Ready-to-use infrastructure stacks for rapid deployment and destruction. Perfect for development, testing, and learning.

## 🚀 Quick Deploy VM Stacks

Deploy a fully-configured VM with networking and SSH access in under 3 minutes.

### Available Stacks

| Cloud | Stack | Cost | Time | Description |
|-------|-------|------|------|-------------|
| **Azure** | [vm](azure/vm/) | ~$12/mo | 2-3 min | Ubuntu 22.04 LTS with VNet, Public IP, SSH |
| **AWS** | [vm](aws/vm/) | FREE* | 2-3 min | Amazon Linux 2023 with VPC, Security Group, SSH |
| **GCP** | [vm](gcp/vm/) | FREE* | 2-3 min | Ubuntu 22.04 LTS with VPC, Firewall, SSH |

*AWS: Free tier (750 hrs/month), GCP: Free tier ($300 credit)

### Quick Start

```bash
# Azure
cd azure/vm && cp terraform.tfvars.example terraform.tfvars
az login && terraform init && terraform apply

# AWS
cd aws/vm && cp terraform.tfvars.example terraform.tfvars
aws configure && terraform init && terraform apply

# GCP
cd gcp/vm && cp terraform.tfvars.example terraform.tfvars
gcloud auth login && terraform init && terraform apply
```

**Full guide**: [Quick Deploy Documentation](../../docs/QUICK_DEPLOY.md)

## 🏖️ Sandbox Stacks

Safe, cost-free stacks for learning and experimentation.

### Available Stacks

| Cloud | Stack | Cost | Description |
|-------|-------|------|-------------|
| **Azure** | [sandbox](azure/sandbox/) | FREE | RG, Storage Account, VNet (free tier only) |
| **AWS** | [sandbox](aws/sandbox/) | FREE | VPC, S3, Security Group (free tier only) |
| **GCP** | [sandbox](gcp/sandbox/) | FREE | VPC, Cloud Storage (free tier only) |

These stacks use only free-tier resources perfect for learning Terraform.

## 📚 Usage

### 1. Deploy

```bash
cd stacks/[provider]/[stack-name]
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform apply
```

### 2. Use Your Resources

Each stack provides outputs with connection details:
```bash
terraform output
terraform output ssh_command
terraform output vm_public_ip
```

### 3. Destroy

```bash
terraform destroy
```

**Important**: Always run `terraform destroy` when done to avoid unexpected charges!

## 🎯 Use Cases

- **Development**: Spin up VMs for coding and testing
- **Learning**: Practice Terraform and cloud infrastructure
- **Experimentation**: Try new tools or configurations
- **Temporary Work**: Quick compute for short-term projects
- **CI/CD**: Build agents or runners
- **Proof of Concept**: Test ideas quickly

## 💰 Cost Management

### Free Tier Eligibility

- **AWS**: 750 hours/month of t2.micro/t3.micro for first 12 months
- **GCP**: $300 free credit for 90 days + always-free tier resources
- **Azure**: Free tier available but VM free tier limited

### Cost Savings Tips

1. **Use free tier**: AWS and GCP VM stacks are free-tier eligible
2. **Enable auto-shutdown**: Azure VM stack includes auto-shutdown option
3. **Always destroy**: Run `terraform destroy` when done
4. **Monitor costs**: Set up billing alerts in cloud console
5. **Use small sizes**: All stacks default to smallest instance sizes

## 📖 Documentation

Each stack includes:
- **README.md**: Complete deployment guide
- **terraform.tfvars.example**: Example configuration
- **main.tf**: Terraform code (well-documented)
- **variables.tf**: All configurable options
- **outputs.tf**: Useful outputs (IPs, commands, etc.)

## 🔧 Customization

All stacks are designed to be:
- **Easy to customize**: Modify `terraform.tfvars` or `main.tf`
- **Well-documented**: Inline comments explain each resource
- **Cost-optimized**: Cheapest defaults without sacrificing usability
- **Security-conscious**: SSH-only access, encrypted storage

## 🆘 Need Help?

- Check stack-specific README
- Review [Quick Deploy Guide](../../docs/QUICK_DEPLOY.md)
- See [Troubleshooting](../../docs/TUTORIALS.md#troubleshooting)
- [Open an issue](https://github.com/Canepro/MyTerraform_Templates/issues)
- [Ask in discussions](https://github.com/Canepro/MyTerraform_Templates/discussions)

## 🗂️ Directory Structure

```
stacks/
├── azure/
│   ├── vm/          # Quick-deploy VM
│   └── sandbox/     # Free-tier sandbox
├── aws/
│   ├── vm/          # Quick-deploy VM
│   └── sandbox/     # Free-tier sandbox
└── gcp/
    ├── vm/          # Quick-deploy VM
    └── sandbox/     # Free-tier sandbox
```

Each stack folder contains:
- `main.tf` - Resource definitions
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `README.md` - Complete documentation
- `terraform.tfvars.example` - Example configuration

## ⚡ Quick Commands

```bash
# Initialize
terraform init

# Plan changes
terraform plan

# Apply
terraform apply

# Apply with auto-approve
terraform apply -auto-approve

# Get outputs
terraform output
terraform output ssh_command

# Destroy
terraform destroy

# Destroy with auto-approve
terraform destroy -auto-approve
```

## 🔐 Security Notes

- **SSH Only**: All stacks use SSH key authentication (no passwords)
- **Public IPs**: All VMs have public IPs for easy access (customize for production)
- **Open SSH**: Security groups allow SSH from anywhere (restrict for production)
- **Encrypted Storage**: All disks are encrypted
- **Managed Keys**: Use cloud provider managed keys when available

## 🎓 Learning Path

1. **Start Here**: Deploy a VM stack to one provider
2. **Try All**: Deploy VM stacks to all three clouds
3. **Experiment**: Modify configurations and redeploy
4. **Explore**: Check out sandbox stacks for more resources
5. **Build**: Create your own custom stacks
6. **Go Multi-Cloud**: Deploy across multiple providers

## 📝 Notes

- All stacks are standalone and don't depend on modules (for simplicity)
- Stacks create minimal resources needed for functionality
- Designed for quick deployment and destruction
- Production-ready: Add backups, monitoring, and scaling as needed

---

**Ready to deploy?** Pick a stack and follow its README!

**Questions?** Check the [Quick Deploy Guide](../../docs/QUICK_DEPLOY.md) or open an issue.
