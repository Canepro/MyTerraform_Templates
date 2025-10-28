# Azure Resource Group Module

A Terraform module for creating Azure Resource Groups with consistent tagging and naming conventions.

## Purpose

Resource Groups are the fundamental organizational unit in Azure. They:
- Group related resources for a solution
- Enable lifecycle management (deploy, update, delete together)
- Apply RBAC and policies at the group level
- Organize resources by project, environment, or workload

## Cost

**Always Free** ✅

Resource Groups themselves have no cost. You only pay for the resources deployed within them.

See [COST.md](./COST.md) for detailed cost information.

## Usage

### Basic Example

```hcl
module "resource_group" {
  source = "../../modules/azure/resource-group"

  name     = "rg-myapp-sandbox-001"
  location = "eastus"
  
  tags = {
    environment = "sandbox"
    managed_by  = "terraform"
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
```

### Multiple Resource Groups

```hcl
module "naming_app" {
  source = "../../modules/common/naming"

  prefix      = "myapp"
  environment = "prod"
  suffix      = "app"
}

module "naming_data" {
  source = "../../modules/common/naming"

  prefix      = "myapp"
  environment = "prod"
  suffix      = "data"
}

module "rg_app" {
  source = "../../modules/azure/resource-group"

  name     = module.naming_app.resource_group
  location = "eastus"
  
  tags = {
    environment = "prod"
    tier        = "application"
  }
}

module "rg_data" {
  source = "../../modules/azure/resource-group"

  name     = module.naming_data.resource_group
  location = "eastus"
  
  tags = {
    environment = "prod"
    tier        = "data"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name of the resource group | string | n/a | yes |
| location | Azure region | string | "eastus" | no |
| tags | Tags to apply | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Resource group ID |
| name | Resource group name |
| location | Resource group location |
| tags | Applied tags |

## Azure Regions

Default region is `eastus` (low-cost, widely available).

Other recommended cost-effective regions:
- `eastus2` - East US 2
- `centralus` - Central US
- `westus2` - West US 2
- `northeurope` - North Europe
- `westeurope` - West Europe

## Best Practices

1. **Naming Convention**: Use descriptive names like `rg-<project>-<environment>-<instance>`
2. **Tags**: Always include environment, managed_by, and cost_center tags
3. **Location**: Choose regions close to your users and consider cost differences
4. **Grouping**: Group resources by lifecycle (deploy/delete together)
5. **RBAC**: Assign permissions at the resource group level when possible

## Limitations

- Resource group names must be unique within a subscription
- Cannot move all resource types between groups (check [Azure docs](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/move-support-resources))
- Maximum 980 resource groups per subscription (default)

## References

- [Azure Resource Groups Overview](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)
- [Resource Naming Conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)

