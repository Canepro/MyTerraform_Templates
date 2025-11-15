# AWS VPC Module

Production-ready AWS VPC module with NAT Gateway, VPC Flow Logs, proper routing, and VPC endpoints.

## 🎯 Cost
**VPC Components:** FREE (VPC, Subnets, IGW, Route Tables)  
**NAT Gateway:** ~$32-65/month depending on configuration  
**VPC Flow Logs:** ~$1-10/month depending on traffic and retention  

See [COST.md](./COST.md) for detailed breakdown.

---

## ✨ Features

- ✅ **Public and Private Subnets** - Multi-tier architecture
- ✅ **NAT Gateway** - Internet access for private subnets
- ✅ **Flexible NAT Options** - Single NAT (cost) or per-AZ (HA)
- ✅ **VPC Flow Logs** - Network traffic monitoring
- ✅ **S3 VPC Endpoint** - Cost-free S3 access
- ✅ **Proper Route Tables** - Separate routes for public/private
- ✅ **Multi-AZ Support** - High availability by default
- ✅ **Comprehensive Outputs** - Easy integration with other modules

---

## 📖 Usage

### Basic Usage (Development)

```hcl
module "vpc" {
  source = "../../modules/aws/vpc"
  
  name       = "dev-vpc"
  cidr_block = "10.0.0.0/16"
  
  availability_zones   = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  
  # Cost-optimized for development
  enable_nat_gateway = true
  single_nat_gateway = true  # Single NAT saves ~50% cost
  
  tags = {
    Environment = "dev"
  }
}
```

### Production Usage (High Availability)

```hcl
module "vpc" {
  source = "../../modules/aws/vpc"
  
  name       = "prod-vpc"
  cidr_block = "10.0.0.0/16"
  
  # 3 AZs for high availability
  availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  
  public_subnet_cidrs = [
    "10.0.1.0/26",   # Smaller for public
    "10.0.1.64/26",
    "10.0.1.128/26"
  ]
  
  private_subnet_cidrs = [
    "10.0.10.0/23",  # Larger for private
    "10.0.12.0/23",
    "10.0.14.0/23"
  ]
  
  # High availability configuration
  enable_nat_gateway = true
  single_nat_gateway = false  # NAT per AZ for redundancy
  
  # Enhanced monitoring
  enable_flow_logs         = true
  flow_logs_retention_days = 30
  
  # Cost optimization
  enable_s3_endpoint = true
  
  tags = {
    Environment = "prod"
    Compliance  = "required"
  }
}
```

### Minimal Public-Only VPC

```hcl
module "vpc" {
  source = "../../modules/aws/vpc"
  
  name       = "simple-vpc"
  cidr_block = "10.0.0.0/16"
  
  availability_zones  = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  
  # No private subnets or NAT
  private_subnet_cidrs = []
  enable_nat_gateway   = false
  
  tags = {
    Environment = "test"
  }
}
```

### Private-Only VPC (No Internet)

```hcl
module "vpc" {
  source = "../../modules/aws/vpc"
  
  name       = "isolated-vpc"
  cidr_block = "10.0.0.0/16"
  
  availability_zones = ["us-east-1a", "us-east-1b"]
  
  # No public subnets
  public_subnet_cidrs  = []
  private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  
  enable_nat_gateway = false
  
  # Use VPC endpoints for AWS services
  enable_s3_endpoint = true
  
  tags = {
    Environment = "secure"
  }
}
```

---

## 📥 Inputs

### Required Inputs

| Name | Description | Type |
|------|-------------|------|
| `name` | Name prefix for all resources | `string` |

### Optional Inputs

#### VPC Configuration
| Name | Description | Type | Default |
|------|-------------|------|---------|
| `cidr_block` | CIDR block for VPC | `string` | `"10.0.0.0/16"` |
| `enable_dns_hostnames` | Enable DNS hostnames | `bool` | `true` |
| `enable_dns_support` | Enable DNS support | `bool` | `true` |

#### Subnet Configuration
| Name | Description | Type | Default |
|------|-------------|------|---------|
| `availability_zones` | List of AZs | `list(string)` | `["us-east-1a", "us-east-1b"]` |
| `public_subnet_cidrs` | Public subnet CIDRs | `list(string)` | `["10.0.1.0/24", "10.0.2.0/24"]` |
| `private_subnet_cidrs` | Private subnet CIDRs | `list(string)` | `["10.0.11.0/24", "10.0.12.0/24"]` |
| `map_public_ip_on_launch` | Auto-assign public IPs | `bool` | `true` |

#### NAT Gateway
| Name | Description | Type | Default |
|------|-------------|------|---------|
| `enable_nat_gateway` | Enable NAT Gateway | `bool` | `true` |
| `single_nat_gateway` | Use single NAT (cost savings) | `bool` | `false` |

#### VPC Endpoints
| Name | Description | Type | Default |
|------|-------------|------|---------|
| `enable_s3_endpoint` | Enable S3 endpoint | `bool` | `true` |

#### VPC Flow Logs
| Name | Description | Type | Default |
|------|-------------|------|---------|
| `enable_flow_logs` | Enable flow logs | `bool` | `true` |
| `flow_logs_traffic_type` | Traffic type (ALL/ACCEPT/REJECT) | `string` | `"ALL"` |
| `flow_logs_retention_days` | Log retention days | `number` | `7` |

#### Tags
| Name | Description | Type | Default |
|------|-------------|------|---------|
| `tags` | Additional tags | `map(string)` | `{}` |

---

## 📤 Outputs

### VPC Outputs
| Name | Description |
|------|-------------|
| `vpc_id` | VPC ID |
| `vpc_cidr_block` | VPC CIDR block |
| `vpc_arn` | VPC ARN |

### Subnet Outputs
| Name | Description |
|------|-------------|
| `public_subnet_ids` | List of public subnet IDs |
| `public_subnet_cidrs` | List of public subnet CIDRs |
| `private_subnet_ids` | List of private subnet IDs |
| `private_subnet_cidrs` | List of private subnet CIDRs |

### Gateway Outputs
| Name | Description |
|------|-------------|
| `internet_gateway_id` | Internet Gateway ID |
| `nat_gateway_ids` | NAT Gateway IDs |
| `nat_gateway_public_ips` | NAT Gateway public IPs |

### Route Table Outputs
| Name | Description |
|------|-------------|
| `public_route_table_id` | Public route table ID |
| `private_route_table_ids` | Private route table IDs |

### Other Outputs
| Name | Description |
|------|-------------|
| `s3_vpc_endpoint_id` | S3 VPC endpoint ID |
| `flow_logs_id` | VPC Flow Logs ID |
| `flow_logs_log_group_name` | CloudWatch log group name |

---

## 🏗️ Architecture

### Network Topology

```
┌────────────────────────────────────────────────────────┐
│                    VPC (10.0.0.0/16)                   │
│                                                         │
│  ┌──────────────────┐      ┌──────────────────┐      │
│  │  AZ A            │      │  AZ B            │      │
│  │                  │      │                  │      │
│  │  ┌────────────┐  │      │  ┌────────────┐  │      │
│  │  │ Public     │  │      │  │ Public     │  │      │
│  │  │ 10.0.1/24  │◄─┼──────┼─►│ 10.0.2/24  │  │      │
│  │  │            │  │      │  │            │  │      │
│  │  │ [NAT GW]   │  │      │  │ [NAT GW]   │  │      │
│  │  └─────┬──────┘  │      │  └─────┬──────┘  │      │
│  │        │         │      │        │         │      │
│  │  ┌─────▼──────┐  │      │  ┌─────▼──────┐  │      │
│  │  │ Private    │  │      │  │ Private    │  │      │
│  │  │ 10.0.11/24 │  │      │  │ 10.0.12/24 │  │      │
│  │  │            │  │      │  │            │  │      │
│  │  │ [Resources]│  │      │  │ [Resources]│  │      │
│  │  └────────────┘  │      │  └────────────┘  │      │
│  └──────────────────┘      └──────────────────┘      │
│                                                         │
│  [Internet Gateway] ◄──────► Internet                 │
│  [S3 Endpoint]      ◄──────► S3                       │
│  [Flow Logs]        ──────► CloudWatch                │
└────────────────────────────────────────────────────────┘
```

### Traffic Flow

**Public Subnet Traffic:**
```
Resource → Route Table → Internet Gateway → Internet
```

**Private Subnet Traffic (with NAT):**
```
Resource → Route Table → NAT Gateway → Internet Gateway → Internet
```

**S3 Access (with VPC Endpoint):**
```
Resource → Route Table → S3 VPC Endpoint → S3
(No internet routing, no data transfer charges!)
```

---

## 💡 Best Practices

### 1. CIDR Planning

**Reserve space for growth:**
```hcl
# Use /16 for VPC (65,536 IPs)
cidr_block = "10.0.0.0/16"

# Smaller public subnets (fewer resources)
public_subnet_cidrs = ["10.0.1.0/26", "10.0.1.64/26"]  # 64 IPs each

# Larger private subnets (more resources)
private_subnet_cidrs = ["10.0.10.0/23", "10.0.12.0/23"]  # 512 IPs each
```

### 2. High Availability

**Always use at least 2 AZs:**
```hcl
availability_zones = ["us-east-1a", "us-east-1b"]

# Production: 3 AZs recommended
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
```

### 3. NAT Gateway Strategy

**Development/Staging:**
```hcl
single_nat_gateway = true  # Cost: ~$32/month
```

**Production:**
```hcl
single_nat_gateway = false  # Cost: ~$32/month × # of AZs
# Benefit: No single point of failure
```

### 4. Cost Optimization

```hcl
# Enable S3 endpoint (saves data transfer costs)
enable_s3_endpoint = true

# Adjust flow log retention for non-prod
flow_logs_retention_days = 7  # vs 30 for prod
```

### 5. Security

```hcl
# Always enable flow logs
enable_flow_logs = true

# Use private subnets for backend resources
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]

# Enable DNS for service discovery
enable_dns_hostnames = true
enable_dns_support   = true
```

---

## 🎓 Common Patterns

### Web Application (3-Tier)

```hcl
# Public: Load Balancers, Bastion
# Private: Application Servers, Databases
# NAT: Private instances access internet

public_subnet_cidrs  = ["10.0.1.0/26", "10.0.1.64/26"]    # Small
private_subnet_cidrs = ["10.0.10.0/23", "10.0.12.0/23"]   # Large
enable_nat_gateway   = true
```

### Microservices (ECS/EKS)

```hcl
# Public: Load Balancers
# Private: Container clusters, databases

public_subnet_cidrs  = ["10.0.1.0/26", "10.0.1.64/26"]
private_subnet_cidrs = ["10.0.10.0/22", "10.0.14.0/22"]   # Very large
enable_nat_gateway   = true
enable_s3_endpoint   = true  # Container images, logs
```

### Isolated Environment

```hcl
# No internet access, VPC endpoints only

public_subnet_cidrs  = []
private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
enable_nat_gateway   = false
enable_s3_endpoint   = true
```

---

## 🔧 Advanced Configuration

### Custom Flow Logs

```hcl
module "vpc" {
  source = "../../modules/aws/vpc"
  
  name = "monitored-vpc"
  
  enable_flow_logs            = true
  flow_logs_traffic_type      = "REJECT"  # Only rejected traffic
  flow_logs_retention_days    = 90        # Compliance requirement
  
  # ... other config
}
```

### Disable Specific Features

```hcl
module "vpc" {
  source = "../../modules/aws/vpc"
  
  name = "minimal-vpc"
  
  # Disable optional features
  enable_nat_gateway = false
  enable_s3_endpoint = false
  enable_flow_logs   = false
  
  # ... other config
}
```

---

## 🚨 Troubleshooting

### Issue: NAT Gateway not working

**Symptoms:** Private instances can't reach internet

**Check:**
1. ✅ `enable_nat_gateway = true`
2. ✅ Instances are in private subnets
3. ✅ Private route table has NAT route
4. ✅ Security groups allow outbound traffic

### Issue: High costs

**Solutions:**
```hcl
# Use single NAT for non-prod
single_nat_gateway = true  # Saves ~50%

# Enable VPC endpoints
enable_s3_endpoint = true  # No data charges

# Reduce log retention
flow_logs_retention_days = 7  # vs 30
```

### Issue: Running out of IPs

**Solutions:**
```hcl
# Use larger CIDR blocks
vpc_cidr = "10.0.0.0/16"  # 65,536 IPs

# Or smaller subnet masks
private_subnet_cidrs = ["10.0.0.0/22"]  # 1,024 IPs vs /24 (256)
```

---

## 🔗 Integration Examples

### With EC2 Module

```hcl
module "vpc" {
  source = "../../modules/aws/vpc"
  name   = "app-vpc"
  # ... config
}

module "ec2" {
  source    = "../../modules/aws/ec2-instance"
  name      = "app-server"
  subnet_id = module.vpc.private_subnet_ids[0]
  # ... config
}
```

### With RDS Module

```hcl
module "vpc" {
  source = "../../modules/aws/vpc"
  name   = "db-vpc"
  # ... config
}

resource "aws_db_subnet_group" "this" {
  subnet_ids = module.vpc.private_subnet_ids
}

resource "aws_db_instance" "this" {
  db_subnet_group_name = aws_db_subnet_group.this.name
  # ... config
}
```

---

## 📚 Resources

- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [AWS NAT Gateway](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html)
- [VPC Flow Logs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html)
- [VPC Endpoints](https://docs.aws.amazon.com/vpc/latest/privatelink/vpc-endpoints.html)

---

## 📝 Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | ~> 5.0 |

---

## 👥 Maintainers

See repository contributors.

## 📄 License

See repository license.
