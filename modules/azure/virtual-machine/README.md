# Azure Linux Virtual Machine Module

A Terraform module for creating Azure Linux Virtual Machines with cost-safe defaults, SSH-only authentication, and optional auto-shutdown.

## Purpose

Deploy Linux VMs for:
- **Development/Testing**: Cost-effective dev environments
- **Application Hosting**: Web servers, APIs, microservices
- **Bastion/Jump Boxes**: Secure access to private networks
- **Build Agents**: CI/CD runners

## Cost

**Pay-as-you-go** ⚠️

- **Standard_B1s**: ~$7.59/month (1 vCPU, 1 GB RAM) - cheapest option
- **Standard_B2s**: ~$30.37/month (2 vCPU, 4 GB RAM)
- **Storage**: ~$1.54/month for 30 GB Standard HDD

**Total minimum**: ~$9/month for always-on B1s VM

See [COST.md](./COST.md) for detailed cost information and savings strategies.

## Features

- ✅ **Ubuntu 22.04 LTS** by default
- ✅ **SSH-only** authentication (no passwords)
- ✅ **Cost-optimized** defaults (Standard_B1s, Standard_LRS storage)
- ✅ **Auto-shutdown** schedule (optional, saves costs)
- ✅ **Managed identity** support
- ✅ **Public IP** optional

## How to Use

### Basic Example (Private IP Only)

```hcl
module "vm" {
  source = "../../modules/azure/virtual-machine"

  name                = "vm-myapp-dev"
  resource_group_name = "rg-myapp-dev"
  location            = "eastus"
  subnet_id           = azurerm_subnet.default.id
  
  # Your SSH public key
  ssh_public_key = file("~/.ssh/id_rsa.pub")
  
  tags = {
    environment = "dev"
    managed_by  = "terraform"
  }
}
```

### With Public IP and Auto-Shutdown

```hcl
module "vm_dev" {
  source = "../../modules/azure/virtual-machine"

  name                = "vm-myapp-dev"
  resource_group_name = "rg-myapp-dev"
  location            = "eastus"
  subnet_id           = azurerm_subnet.default.id
  ssh_public_key      = file("~/.ssh/id_rsa.pub")
  
  # Enable public IP for external access
  enable_public_ip = true
  
  # Auto-shutdown at 7 PM to save costs
  enable_auto_shutdown = true
  auto_shutdown_time   = "1900"
  auto_shutdown_timezone = "Eastern Standard Time"
  
  tags = {
    environment = "dev"
    auto_shutdown = "enabled"
  }
}

# SSH access
output "ssh_command" {
  value = "ssh ${module.vm_dev.admin_username}@${module.vm_dev.public_ip_address}"
}
```

### With Complete Stack

```hcl
module "naming" {
  source = "../../modules/common/naming"

  prefix      = "myapp"
  environment = "dev"
}

module "tags" {
  source = "../../modules/common/tags"

  environment = "dev"
  cost_center = "engineering"
}

module "resource_group" {
  source = "../../modules/azure/resource-group"

  name     = module.naming.resource_group
  location = "eastus"
  tags     = module.tags.tags
}

module "vnet" {
  source = "../../modules/azure/virtual-network"

  name                = module.naming.virtual_network
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  address_space       = ["10.0.0.0/16"]
  
  subnets = [
    {
      name             = "snet-vm"
      address_prefixes = ["10.0.1.0/24"]
    }
  ]
  
  tags = module.tags.tags
}

module "vm" {
  source = "../../modules/azure/virtual-machine"

  name                = module.naming.virtual_machine
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  subnet_id           = module.vnet.subnet_ids["snet-vm"]
  ssh_public_key      = file("~/.ssh/id_rsa.pub")
  
  vm_size          = "Standard_B1s"
  enable_public_ip = true
  
  # Auto-shutdown for cost savings
  enable_auto_shutdown = true
  auto_shutdown_time   = "2000"
  
  tags = module.tags.tags
}
```

### Different VM Sizes

```hcl
# Cheapest (1 vCPU, 1 GB RAM) - ~$7.59/month
module "vm_small" {
  source = "../../modules/azure/virtual-machine"
  # ... other config ...
  vm_size = "Standard_B1s"
}

# Balanced (2 vCPU, 4 GB RAM) - ~$30/month
module "vm_medium" {
  source = "../../modules/azure/virtual-machine"
  # ... other config ...
  vm_size = "Standard_B2s"
}

# Larger (2 vCPU, 8 GB RAM) - ~$60/month
module "vm_large" {
  source = "../../modules/azure/virtual-machine"
  # ... other config ...
  vm_size = "Standard_B2ms"
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | VM name | string | n/a | yes |
| resource_group_name | Resource group name | string | n/a | yes |
| subnet_id | Subnet ID | string | n/a | yes |
| ssh_public_key | SSH public key | string | n/a | yes |
| location | Azure region | string | "eastus" | no |
| vm_size | VM size | string | "Standard_B1s" | no |
| admin_username | Admin username | string | "azureuser" | no |
| enable_public_ip | Enable public IP | bool | false | no |
| os_disk_storage_account_type | Storage type | string | "Standard_LRS" | no |
| os_disk_size_gb | OS disk size | number | 30 | no |
| enable_managed_identity | Enable managed identity | bool | false | no |
| enable_auto_shutdown | Enable auto-shutdown | bool | false | no |
| auto_shutdown_time | Shutdown time (HHMM) | string | "1900" | no |
| tags | Resource tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| id | VM ID |
| name | VM name |
| private_ip_address | Private IP |
| public_ip_address | Public IP (if enabled) |
| admin_username | SSH username |
| network_interface_id | NIC ID |
| identity_principal_id | Managed identity principal ID (if enabled) |

## SSH Access

After deployment, connect via SSH:

```bash
# Generate SSH key if you don't have one
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa

# SSH to VM (private IP)
ssh azureuser@<private-ip>

# SSH to VM (public IP, if enabled)
ssh azureuser@<public-ip>

# SSH with specific key
ssh -i ~/.ssh/id_rsa azureuser@<ip-address>
```

## Auto-Shutdown

Enable auto-shutdown to save costs:

```hcl
enable_auto_shutdown       = true
auto_shutdown_time         = "1900"  # 7 PM
auto_shutdown_timezone     = "Eastern Standard Time"
auto_shutdown_notification_enabled = false
```

**Cost Savings**: If VM runs only 8 hours/day (shutdown 16 hours):
- Standard_B1s: ~$7.59/month → **~$2.53/month** (67% savings)

## Best Practices

1. **Use auto-shutdown** - Enable for dev/test VMs
2. **Start with B-series** - Cheapest option (Standard_B1s)
3. **Use managed identity** - Instead of storing credentials
4. **Private IPs only** - Use Azure Bastion or VPN for access
5. **Standard_LRS storage** - Cheapest disk option for dev/test
6. **Monitor costs** - Set up cost alerts

## Security Features

- ✅ **SSH-only** - Passwords disabled by default
- ✅ **No public IP** by default - Deploy in private subnet
- ✅ **Managed identity** - For Azure resource access
- ✅ **NSG integration** - Use with network security groups
- ✅ **Auto-update** - Ubuntu LTS with automatic security updates

## Common Use Cases

### Development Workstation

```hcl
vm_size              = "Standard_B2s"  # 2 vCPU, 4 GB RAM
enable_auto_shutdown = true
auto_shutdown_time   = "1800"  # 6 PM
```

### CI/CD Build Agent

```hcl
vm_size                 = "Standard_B2s"
enable_managed_identity = true  # Access Azure resources
enable_public_ip        = false # Keep private
```

### Jump Box / Bastion

```hcl
vm_size          = "Standard_B1s"  # Minimal resources needed
enable_public_ip = true            # External access
```

## Limitations

- Only Linux VMs supported (use separate module for Windows)
- No data disk configuration (add separately if needed)
- SSH key required (password auth disabled)
- Auto-shutdown doesn't auto-start VMs

## References

- [Azure VM Pricing](https://azure.microsoft.com/en-us/pricing/details/virtual-machines/linux/)
- [VM Sizes](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes)
- [Ubuntu on Azure](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/canonical.0001-com-ubuntu-server-jammy)
