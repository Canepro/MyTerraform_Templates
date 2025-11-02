# AWS EC2 Quick Deploy

Deploy a ready-to-use Amazon Linux 2023 VM in AWS in under 3 minutes with SSH access configured.

## 🚀 Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.5.0
- [AWS CLI](https://aws.amazon.com/cli/)
- AWS account with appropriate permissions
- AWS Key Pair

### Step 1: Create SSH Key Pair in AWS

```bash
# Option 1: AWS Console
# Go to EC2 Dashboard > Key Pairs > Create Key Pair
# Download the .pem file and set permissions

# Option 2: AWS CLI
aws ec2 create-key-pair --key-name my-aws-key --query 'KeyMaterial' --output text > ~/.ssh/my-aws-key.pem
chmod 400 ~/.ssh/my-aws-key.pem
```

**Note**: AWS automatically injects the public key into the instance. You don't need to provide the public key content.

### Step 2: Configure AWS Credentials

```bash
# Method 1: AWS CLI
aws configure

# Method 2: Environment variables
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_DEFAULT_REGION=us-east-1
```

### Step 3: Configure Variables

```bash
cd stacks/aws/vm
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and set your key pair name and path:
```hcl
key_name = "my-aws-key"
key_path = "~/.ssh/my-aws-key.pem"
```

### Step 4: Deploy

```bash
terraform init
terraform plan
terraform apply
```

**That's it!** Your VM is ready in 2-3 minutes. The SSH command will be in the output:

```
ssh ec2-user@52.168.123.45 -i ~/.ssh/my-aws-key.pem
```

## 📋 What Gets Created

- ✅ VPC (10.0.0.0/16)
- ✅ Internet Gateway
- ✅ Public Subnet (10.0.1.0/24)
- ✅ Route Table with Internet access
- ✅ Security Group (SSH port 22 open)
- ✅ Amazon Linux 2023 EC2 Instance (t3.micro)
- ✅ Elastic IP (optional, for static IP)

## 💰 Cost

- **t3.micro**: FREE (750 hours/month for first 12 months)
- **gp3 Disk**: ~$2.50/month for 30GB
- **EIP (if attached)**: FREE when attached to running instance
- **Networking**: FREE
- **Total First Year**: ~$2.50/month (within free tier)
- **Total After Free Tier**: ~$7.50/month

**Free tier includes**:
- 750 hours/month of t2.micro or t3.micro
- 30GB gp2 storage

## 🔧 Configuration Options

See [terraform.tfvars.example](terraform.tfvars.example) for all available options:

- `project_name`: Name prefix for all resources
- `environment`: Environment tag
- `region`: AWS region (us-east-1 is cheapest)
- `instance_type`: EC2 instance size
- `key_name`: AWS key pair name
- `key_path`: Path to your SSH private key (.pem file)
- `root_volume_type`: Storage type (gp3 recommended)
- `enable_eip`: Enable static public IP

## 🖥️ Connect to Your VM

After deployment:

```bash
# Just use the output command - it includes everything you need
terraform output ssh_command

# Or get just the IP
terraform output vm_public_ip
```

**Default username**: `ec2-user` (Amazon Linux)

## 🧹 Destroy Everything

When you're done:

```bash
terraform destroy
```

This removes all created resources and stops all billing.

## 📊 VM Details

| Property | Value |
|----------|-------|
| **OS** | Amazon Linux 2023 |
| **Size** | t3.micro (2 vCPU, 1GB RAM) |
| **Disk** | 30GB gp3 SSD |
| **Network** | Public IP + VPC |
| **SSH** | Port 22 open to the world |

## 🔍 Troubleshooting

### "Could not find key pair"
Make sure the key pair name matches exactly what you created in AWS:
```bash
aws ec2 describe-key-pairs
```

### "Permission denied (publickey)"
Use the correct username for your OS:
- Amazon Linux: `ec2-user`
- Ubuntu: `ubuntu`
- RHEL: `ec2-user`
- Debian: `admin`

### "Connection refused"
Wait 1-2 minutes for the instance to fully boot and run cloud-init.

### "InvalidKeyPair.NotFound"
The key pair must exist in the same region as your instance. Check with:
```bash
aws ec2 describe-key-pairs --region us-east-1
```

## 🎯 Use Cases

- Development environment
- Testing applications
- Learning AWS infrastructure
- Temporary compute needs
- CI/CD build agents
- Personal cloud services

## 🔐 Security Best Practices

1. **Use AWS Key Pairs**: Never share private keys
2. **Restrict SSH**: Consider limiting source IP in security group
3. **Enable IMDSv2**: Already enabled in this stack
4. **Use encrypted volumes**: Already enabled
5. **Set up CloudWatch**: Monitor instance health

## 📚 Next Steps

- Add Auto Scaling Group for high availability
- Deploy across multiple AZs
- Add Application Load Balancer
- Configure CloudWatch monitoring
- Set up AWS Systems Manager for access without SSH
- Use AWS Secrets Manager for credentials

## 💡 Tips

- **Free tier**: t3.micro is free for 750 hours/month (first year)
- **Regions**: us-east-1 is typically cheapest
- **Spot instances**: Save up to 90% with spot instances
- **Always destroy**: Run `terraform destroy` when done
- **Monitor costs**: Set up AWS billing alerts

## 🌍 Multi-Region

Deploy to different regions by changing `region` in `terraform.tfvars`:
- `us-east-1` (N. Virginia) - Cheapest
- `us-west-2` (Oregon) - Popular
- `eu-west-1` (Ireland) - Europe
- `ap-southeast-1` (Singapore) - Asia Pacific

## 🤝 Contributing

Found a bug or have a suggestion? [Open an issue](https://github.com/Canepro/MyTerraform_Templates/issues) or submit a PR.

## 📄 License

MIT License - Copyright (c) 2025
