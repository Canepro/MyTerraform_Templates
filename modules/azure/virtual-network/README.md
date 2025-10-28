# Azure Virtual Network Module

A Terraform module for creating Azure Virtual Networks (VNets) with flexible subnet configuration and service endpoints.

## Purpose

Azure Virtual Networks provide:
- **Network isolation**: Private IP address space for your resources
- **Segmentation**: Organize resources into subnets
- **Connectivity**: Connect Azure resources securely
- **Service endpoints**: Direct routes to Azure PaaS services
- **Hybrid connectivity**: Extend on-premises networks (via VPN/ExpressRoute)

## Cost

**Always Free** ✅

Virtual Networks themselves have no cost. You only pay for optional add-ons like:
- VPN Gateways (~$27+/month)
- NAT Gateways (~$33+/month)
- Private Endpoints (~$7/month)

See [COST.md](./COST.md) for detailed cost information.

## Default Configuration

This module creates cost-safe VNets:
- **No gateways**: No VPN, NAT, or application gateways
- **No private endpoints**: Created separately if needed
- **Azure default DNS**: No custom DNS infrastructure cost
- **Flexible subnets**: Create as many as needed (free)

## Usage

### Basic VNet (No Subnets)

```hcl
module "vnet" {
  source = "../../modules/azure/virtual-network"

  name                = "vnet-myapp-sandbox"
  resource_group_name = "rg-myapp-sandbox"
  location            = "eastus"
  address_space       = ["10.0.0.0/16"]
  
  tags = {
    environment = "sandbox"
    managed_by  = "terraform"
  }
}
```

### VNet with Subnets

```hcl
module "vnet" {
  source = "../../modules/azure/virtual-network"

  name                = "vnet-myapp-dev"
  resource_group_name = "rg-myapp-dev"
  location            = "eastus"
  address_space       = ["10.1.0.0/16"]
  
  subnets = [
    {
      name             = "snet-web"
      address_prefixes = ["10.1.1.0/24"]
    },
    {
      name             = "snet-app"
      address_prefixes = ["10.1.2.0/24"]
    },
    {
      name             = "snet-data"
      address_prefixes = ["10.1.3.0/24"]
    }
  ]
  
  tags = {
    environment = "dev"
  }
}
```

### With Service Endpoints (Storage, Key Vault)

```hcl
module "vnet" {
  source = "../../modules/azure/virtual-network"

  name                = "vnet-myapp-prod"
  resource_group_name = "rg-myapp-prod"
  location            = "eastus"
  address_space       = ["10.2.0.0/16"]
  
  subnets = [
    {
      name             = "snet-app"
      address_prefixes = ["10.2.1.0/24"]
      service_endpoints = [
        "Microsoft.Storage",
        "Microsoft.KeyVault",
        "Microsoft.Sql"
      ]
    }
  ]
  
  tags = {
    environment = "prod"
  }
}
```

### With Common Modules

```hcl
module "naming" {
  source = "../../modules/common/naming"

  prefix      = "myapp"
  environment = "sandbox"
}

module "tags" {
  source = "../../modules/common/tags"

  environment = "sandbox"
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
      name             = module.naming.subnet
      address_prefixes = ["10.0.1.0/24"]
    }
  ]
  
  tags = module.tags.tags
}
```

### Hub-and-Spoke Topology

```hcl
# Hub VNet (shared services)
module "vnet_hub" {
  source = "../../modules/azure/virtual-network"

  name                = "vnet-hub-prod"
  resource_group_name = "rg-network-prod"
  location            = "eastus"
  address_space       = ["10.0.0.0/16"]
  
  subnets = [
    {
      name             = "GatewaySubnet"  # For VPN/ExpressRoute
      address_prefixes = ["10.0.0.0/27"]
    },
    {
      name             = "AzureFirewallSubnet"
      address_prefixes = ["10.0.1.0/26"]
    }
  ]
}

# Spoke VNet (application)
module "vnet_spoke_app" {
  source = "../../modules/azure/virtual-network"

  name                = "vnet-spoke-app-prod"
  resource_group_name = "rg-app-prod"
  location            = "eastus"
  address_space       = ["10.1.0.0/16"]
  
  subnets = [
    {
      name             = "snet-web"
      address_prefixes = ["10.1.1.0/24"]
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Virtual network name | string | n/a | yes |
| resource_group_name | Resource group name | string | n/a | yes |
| location | Azure region | string | "eastus" | no |
| address_space | VNet address space (CIDR) | list(string) | ["10.0.0.0/16"] | no |
| dns_servers | Custom DNS servers | list(string) | [] | no |
| subnets | Subnet configurations | list(object) | [] | no |
| tags | Resource tags | map(string) | {} | no |

### Subnet Object Structure

```hcl
{
  name             = string          # Required: Subnet name
  address_prefixes = list(string)    # Required: CIDR blocks
  service_endpoints = list(string)   # Optional: Service endpoints
  delegations = list(object({        # Optional: Subnet delegations
    name         = string
    service_name = string
    actions      = list(string)
  }))
}
```

## Outputs

| Name | Description |
|------|-------------|
| id | Virtual network ID |
| name | Virtual network name |
| address_space | VNet address space |
| subnet_ids | Map of subnet names to IDs |
| subnet_address_prefixes | Map of subnet names to address ranges |

## Common Address Spaces

| Size | CIDR | Usable IPs | Use Case |
|------|------|------------|----------|
| /16 | 10.0.0.0/16 | 65,536 | Large enterprise network |
| /20 | 10.0.0.0/20 | 4,096 | Medium network |
| /24 | 10.0.0.0/24 | 256 | Small project/subnet |
| /27 | 10.0.0.0/27 | 32 | Minimal subnet (GatewaySubnet) |

**Azure reserves 5 IPs per subnet** (first 4 and last 1), so a /24 gives you 251 usable IPs.

## Service Endpoints

Enable direct routes to Azure services (no cost):

- `Microsoft.Storage` - Storage Accounts
- `Microsoft.Sql` - Azure SQL Database
- `Microsoft.KeyVault` - Key Vault
- `Microsoft.ContainerRegistry` - Container Registry
- `Microsoft.ServiceBus` - Service Bus
- `Microsoft.EventHub` - Event Hubs

## Best Practices

1. **Plan address space carefully** - Difficult to change later
2. **Use RFC 1918 ranges**: 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
3. **Avoid overlaps** - With on-premises networks or other VNets
4. **Segment by tier** - Separate subnets for web, app, data layers
5. **Reserve space** - Leave room for future subnets
6. **Service endpoints over private endpoints** - For cost savings (service endpoints are free)

## Limitations

- Address space cannot overlap with peered VNets
- GatewaySubnet must be named exactly "GatewaySubnet"
- Some services require dedicated subnets (AKS, App Service, etc.)
- Maximum 1000 subnets per VNet

## References

- [Azure Virtual Networks Overview](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview)
- [VNet Pricing](https://azure.microsoft.com/en-us/pricing/details/virtual-network/)
- [Service Endpoints](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview)

