# Unified Module Interface

This repository implements a **unified interface** across AWS and Azure VM modules, enabling consistent deployments with environment-driven defaults and sandbox-safe configurations.

## 🎯 Core Principles

1. **Modular Design**: Reusable modules under `/modules`, deployable stacks under `/stacks`
2. **Unified Variables**: Same variable names across clouds (AWS ↔ Azure)
3. **Environment Profiles**: Automatic sizing based on `dev`, `training`, or `prod`
4. **Sandbox Safety**: 4-hour auto-shutdown by default
5. **Cost-Conscious**: Free-tier and budget-friendly defaults
6. **One-Command Deploy**: `terraform apply -var-file=terraform.tfvars.{env}`

## 🔄 Variable Mapping

### Compute Sizing

| Concept | AWS Variable | Azure Variable | Shared Default |
|---------|--------------|----------------|----------------|
| Instance size | `instance_type` | `vm_size` | `null` (uses environment profile) |
| Disk size | `root_volume_size` | `os_disk_size_gb` | `null` (uses environment profile) |
| Disk type | `root_volume_type` | `os_disk_storage_account_type` | `gp3` / `Standard_LRS` |

### Networking & Security

| Concept | AWS Variable | Azure Variable | Default |
|---------|--------------|----------------|---------|
| Allowed ports | `allowed_ports` | `allowed_ports` | `[22, 80, 8080]` |
| Allowed CIDRs | `allowed_cidrs` | `allowed_cidrs` | `["0.0.0.0/0"]` |
| Static IP | `enable_eip` | `enable_public_ip` | `true` |
| Network ID | `vpc_id` | *(created by stack)* | `null` (default VPC) |
| Subnet ID | `subnet_id` | `subnet_id` | `null` (default subnet) |

### Identity & Access

| Concept | AWS Variable | Azure Variable | Notes |
|---------|--------------|----------------|-------|
| SSH key | `key_name` | `ssh_public_key` | AWS uses key pair name, Azure uses public key content |
| Username | *(OS-dependent)* | `admin_username` | `ec2-user` / `ubuntu` vs `azureuser` |
| IAM/Identity | `iam_instance_profile` | `enable_managed_identity` | Different mechanisms |

### Auto-Shutdown

| Concept | AWS Variable | Azure Variable | Default |
|---------|--------------|----------------|---------|
| Enable | `enable_auto_shutdown` | `enable_auto_shutdown` | `true` |
| Hours | `auto_shutdown_hours` | `auto_shutdown_hours` | `4` |
| Timezone | *(N/A)* | `auto_shutdown_timezone` | `UTC` |

### Tagging

| Concept | AWS Variable | Azure Variable | Default |
|---------|--------------|----------------|---------|
| Project | `project` | `project` | `"quickvm"` |
| Environment | `environment` | `environment` | `"training"` |
| Extra tags | `tags` | `tags` | `{}` |

## 📊 Environment Profiles

Both modules automatically select instance sizing based on the `environment` variable:

### AWS (EC2)

```hcl
dev = {
  instance_type    = "t3.micro"
  root_volume_size = 30
}
training = {
  instance_type    = "t3.medium"
  root_volume_size = 50
}
prod = {
  instance_type    = "t3.large"
  root_volume_size = 100
}
```

### Azure (VM)

```hcl
dev = {
  vm_size        = "Standard_B1s"
  os_disk_size_gb = 30
}
training = {
  vm_size        = "Standard_B2ms"
  os_disk_size_gb = 50
}
prod = {
  vm_size        = "Standard_D2s_v3"
  os_disk_size_gb = 100
}
```

## 🚀 Usage Pattern

### AWS Deployment

```bash
cd stacks/aws/vm

# Edit terraform.tfvars
cat > terraform.tfvars <<EOF
project_name = "myapp"
environment  = "training"
key_name     = "my-aws-key"
allowed_cidrs = ["203.0.113.0/24"]
EOF

# Deploy
terraform init
terraform apply
```

### Azure Deployment

```bash
cd stacks/azure/vm

# Edit terraform.tfvars
cat > terraform.tfvars <<EOF
project_name   = "myapp"
environment    = "training"
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2E..."
allowed_cidrs  = ["203.0.113.0/24"]
EOF

# Deploy
terraform init
terraform apply
```

## 🔧 OS Selection

### AWS

```hcl
os_distribution = "amazon-linux"  # Default
# or
os_distribution = "ubuntu"
```

### Azure

```hcl
os_distribution = "ubuntu"       # Default
# or
os_distribution = "azure-linux"  # CBL-Mariner
```

## 💡 Design Decisions

### Why Different SSH Mechanisms?

- **AWS**: Uses key pair names because AWS manages the public key injection
- **Azure**: Requires the full public key content in the Terraform config

### Why Default VPC for AWS?

- Sandbox environments often have VPC limits
- Default VPC is free and always available
- Reduces resource creation overhead
- Can still override with `vpc_id` and `subnet_id`

### Why Create VNet for Azure?

- Azure doesn't have a "default VNet" concept
- VNets are free and required for VM deployment
- Provides consistent networking setup

### Why 4-Hour Auto-Shutdown?

- Prevents surprise costs in sandbox/training environments
- Long enough for workshops and demos
- Can be disabled for production (`enable_auto_shutdown = false`)

## 📁 Repository Structure

```
MyTerraform_Templates/
├── modules/
│   ├── aws/
│   │   └── ec2-instance/          # Unified AWS EC2 module
│   │       ├── main.tf
│   │       ├── variables.tf       # Unified interface
│   │       ├── outputs.tf
│   │       ├── README.md
│   │       └── COST.md
│   └── azure/
│       └── virtual-machine/       # Unified Azure VM module
│           ├── main.tf
│           ├── variables.tf       # Unified interface
│           ├── outputs.tf
│           ├── README.md
│           └── COST.md
├── stacks/
│   ├── aws/
│   │   └── vm/                    # AWS deployment stack
│   │       ├── main.tf            # Consumes ec2-instance module
│   │       ├── variables.tf
│   │       ├── outputs.tf
│   │       ├── terraform.tfvars.dev
│   │       ├── terraform.tfvars.training
│   │       ├── terraform.tfvars.prod
│   │       └── README.md
│   └── azure/
│       └── vm/                    # Azure deployment stack
│           ├── main.tf            # Consumes virtual-machine module
│           ├── variables.tf
│           ├── outputs.tf
│           ├── terraform.tfvars.dev
│           ├── terraform.tfvars.training
│           ├── terraform.tfvars.prod
│           └── README.md
└── docs/
    ├── BEGINNER_GUIDE.md          # Step-by-step for newcomers
    ├── UNIFIED_INTERFACE.md       # This document
    ├── module-guidelines.md
    └── stack-guidelines.md
```

## ✅ Benefits

1. **Consistency**: Same variable names, same deployment patterns
2. **Flexibility**: Environment profiles with override capability
3. **Safety**: Auto-shutdown prevents runaway costs
4. **Simplicity**: One command per environment
5. **Portability**: Easy to switch between clouds
6. **Maintainability**: Centralized logic in modules

## 🎓 Next Steps

- [Beginner's Guide](./BEGINNER_GUIDE.md) - Start here if you're new
- [AWS Module Docs](../modules/aws/ec2-instance/README.md)
- [Azure Module Docs](../modules/azure/virtual-machine/README.md)
- [AWS Stack README](../stacks/aws/vm/README.md)
- [Azure Stack README](../stacks/azure/vm/README.md)

---

**Unified Interface** | **Environment-Driven** | **Cost-Conscious** | **Sandbox-Safe**

