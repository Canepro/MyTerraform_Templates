# AWS EC2 Instance Module

A Terraform module for creating AWS EC2 instances with security best practices, cost-optimized defaults, and production-ready configurations.

## Purpose

Deploy EC2 instances for:
- **Application Hosting**: Web servers, APIs, microservices
- **Development/Testing**: Cost-effective dev environments
- **Jump Boxes**: Secure access to private networks
- **Build Agents**: CI/CD runners
- **Container Hosting**: ECS or EKS worker nodes

## Cost

**Pay-as-you-go** ⚠️

- **t2.micro**: ~$9/month (750 hours FREE in first 12 months) ✅
- **t3.micro**: ~$8/month (default)
- **t4g.nano**: ~$4/month (ARM-based, cheapest)
- **EBS Storage**: ~$0.64/month for 8GB gp3

**Total minimum**: ~$9/month for always-on t2.micro (after free tier)

See [COST.md](./COST.md) for detailed cost information and savings strategies.

## Features

- ✅ **Amazon Linux 2023** support by default
- ✅ **IMDSv2 enforced** for security
- ✅ **EBS encryption enabled** by default
- ✅ **Cost-optimized** defaults (gp3 volumes, t3.micro)
- ✅ **IAM instance profile** support
- ✅ **CloudWatch monitoring** optional
- ✅ **Termination protection** optional

## How to Use

### Basic Example (Recommended: Auto-Detect Latest AMI)

```hcl
module "ec2_instance" {
  source = "../../modules/aws/ec2-instance"

  name           = "my-app-server"
  use_latest_ami = true  # Automatically use latest Amazon Linux 2023
  instance_type  = "t3.micro"
  subnet_id      = "subnet-12345678"
  
  security_group_ids = ["sg-12345678"]
  
  tags = {
    environment = "dev"
    managed_by  = "terraform"
  }
}
```

### With Specific AMI ID

```hcl
module "ec2_instance" {
  source = "../../modules/aws/ec2-instance"

  name         = "my-app-server"
  ami_id       = "ami-0c55b159cbfafe1f0"  # Specific AMI ID
  instance_type = "t3.micro"
  subnet_id    = "subnet-12345678"
  
  security_group_ids = ["sg-12345678"]
  
  tags = {
    environment = "dev"
    managed_by  = "terraform"
  }
}
```

### With IAM Role and User Data

```hcl
module "ec2_instance" {
  source = "../../modules/aws/ec2-instance"

  name           = "my-app-server"
  use_latest_ami = true  # Automatically use latest Amazon Linux 2023
  instance_type  = "t3.micro"
  subnet_id      = aws_subnet.main.id
  security_group_ids = [aws_security_group.ec2.id]
  
  # IAM role for S3 access
  iam_instance_profile = aws_iam_instance_profile.ec2.name
  
  # Bootstrap script
  user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
  EOF
  )
  
  tags = {
    environment = "prod"
    role        = "web-server"
  }
}
```

### With Complete VPC Stack

```hcl
# VPC
module "vpc" {
  source = "../../modules/aws/vpc"

  name               = "myapp-vpc"
  cidr_block         = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  public_subnets = [
    {
      name             = "public-1"
      cidr_block       = "10.0.1.0/24"
      availability_zone = "us-east-1a"
    }
  ]
  
  tags = {
    environment = "prod"
  }
}

# Security Group
resource "aws_security_group" "web" {
  name_prefix = "web-"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_IP/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

# EC2 Instance
module "web_server" {
  source = "../../modules/aws/ec2-instance"

  name               = "web-server"
  ami_id             = "ami-0c55b159cbfafe1f0"
  instance_type      = "t3.micro"
  subnet_id          = module.vpc.public_subnet_ids["public-1"]
  security_group_ids = [aws_security_group.web.id]
  
  # SSH key pair
  key_name = "my-keypair"
  
  # Enable CloudWatch detailed monitoring
  enable_detailed_monitoring = true
  
  # Enable termination protection for production
  enable_termination_protection = true
  
  tags = {
    environment = "prod"
    role        = "web-server"
  }
}

# Output SSH command
output "ssh_command" {
  value = "ssh ec2-user@${module.web_server.public_ip}"
}
```

### Free Tier Configuration

```hcl
module "free_tier_instance" {
  source = "../../modules/aws/ec2-instance"

  name          = "free-tier-server"
  ami_id        = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2023
  instance_type = "t2.micro"               # Free tier eligible
  subnet_id     = "subnet-12345678"
  
  # Minimum storage (free tier: 30GB)
  root_volume_size = 8
  
  tags = {
    environment = "sandbox"
  }
}
```

### ARM-based (Cost Optimization)

```hcl
module "arm_instance" {
  source = "../../modules/aws/ec2-instance"

  name          = "arm-server"
  ami_id        = "ami-0c7a8b42e4b7e2e07"  # Amazon Linux 2023 ARM
  instance_type = "t4g.nano"               # ARM, cheapest option
  subnet_id     = "subnet-12345678"
  
  tags = {
    environment = "dev"
    architecture = "arm"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name tag for the EC2 instance | string | - | yes |
| use_latest_ami | Auto-detect latest Amazon Linux 2023 AMI | bool | `false` | no |
| ami_id | AMI ID (required if use_latest_ami is false) | string | `""` | no* |
| instance_type | EC2 instance type | string | `"t3.micro"` | no |
| subnet_id | Subnet ID where instance will be launched | string | - | yes |

*Either `use_latest_ami = true` OR `ami_id` must be provided
| security_group_ids | List of security group IDs | list(string) | `[]` | no |
| key_name | Name of the SSH key pair | string | `null` | no |
| root_volume_type | Root volume type | string | `"gp3"` | no |
| root_volume_size | Root volume size in GB | number | `8` | no |
| enable_detailed_monitoring | Enable detailed CloudWatch monitoring | bool | `false` | no |
| user_data | User data script to run on launch | string | `null` | no |
| iam_instance_profile | IAM instance profile name | string | `null` | no |
| enable_termination_protection | Enable termination protection | bool | `false` | no |
| tags | Tags to apply to instance and volumes | map(string) | `{}` | no |

### Validation Rules

- **name**: 1-255 characters
- **ami_id**: Must match format `ami-xxxxxxxxx`
- **root_volume_type**: Must be one of: `gp2`, `gp3`, `io1`, `io2`, `st1`, `sc1`
- **root_volume_size**: 8-16384 GB

## Outputs

| Name | Description |
|------|-------------|
| instance_id | ID of the EC2 instance |
| instance_arn | ARN of the EC2 instance |
| private_ip | Private IP address |
| public_ip | Public IP address (if assigned) |
| private_dns | Private DNS name |
| public_dns | Public DNS name (if assigned) |
| availability_zone | Availability zone |
| instance_state | State of the instance |

## Best Practices

### Security

1. **Use IMDSv2**: Module enforces IMDSv2 by default ✅
2. **Encrypt volumes**: EBS encryption enabled by default ✅
3. **Principle of least privilege**: Use IAM roles, not hardcoded credentials
4. **Restrict SSH**: Limit security group to specific IPs
5. **Use Systems Manager**: For remote access without SSH key exposure

### Cost Optimization

1. **Free Tier**: Use t2.micro for first 12 months
2. **ARM Instances**: t4g.nano/micro are 20% cheaper
3. **Spot Instances**: 90% savings for fault-tolerant workloads
4. **Right-sizing**: Choose instance type based on actual needs
5. **gp3 volumes**: Cheaper and faster than gp2

### High Availability

1. **Multiple AZs**: Deploy instances across availability zones
2. **Auto Scaling**: Use ASG for dynamic capacity
3. **Load Balancer**: Distribute traffic across instances
4. **Health Checks**: Enable CloudWatch health checks

## Security Features

This module implements security best practices:

- ✅ **IMDSv2 enforced**: Metadata service version 2 required
- ✅ **EBS encryption**: All volumes encrypted at rest
- ✅ **TLS 1.2+**: HTTPS endpoints only
- ✅ **No default credentials**: SSH keys or IAM roles required
- ✅ **Private by default**: No public IP unless explicitly enabled

## Troubleshooting

### Instance won't start

```bash
# Check system logs
aws ec2 get-console-output --instance-id i-1234567890abcdef0

# Check instance state
aws ec2 describe-instance-status --instance-ids i-1234567890abcdef0
```

### Can't SSH

1. Verify security group allows port 22 from your IP
2. Check key pair name is correct
3. Verify instance has public IP
4. Try connecting via Systems Manager Session Manager

### High costs

1. Check if detailed monitoring is enabled (disabled by default)
2. Verify instance size matches workload
3. Consider stopping instances when not in use
4. Review EBS volumes for unused storage

## Examples

See the `examples/` directory for complete working configurations:
- Basic web server
- API server with IAM roles
- Auto Scaling Group integration
- Multi-AZ deployment

## References

- [EC2 Pricing](https://aws.amazon.com/ec2/pricing/)
- [EC2 User Guide](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/)
- [AMI Finder](https://console.aws.amazon.com/ec2/v2/home#Images)
- [Amazon Linux 2023](https://aws.amazon.com/linux/amazon-linux-2023/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

---

**Cost**: ~$8/month (t3.micro) ⚠️ | **Free Tier**: t2.micro eligible ✅  
**Last Updated**: 2025-11-02 | **Maintained by**: [@Canepro](https://github.com/Canepro)

