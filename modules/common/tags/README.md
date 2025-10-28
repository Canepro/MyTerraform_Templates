# Common Tags Module

This module provides a standardized tagging strategy for all resources across your Terraform infrastructure. It enforces consistent standard tags and allows for custom tags to be added.

## Purpose

- Enforce organizational tagging standards
- Track resource ownership and cost allocation
- Maintain consistent metadata across environments
- Simplify compliance and auditing

## Standard Tags

The module automatically applies these tags:

- `environment` - Environment name (sandbox, dev, staging, prod)
- `managed_by` - Tool managing the resource (default: terraform)
- `cost_center` - Department or cost center for billing
- `created_date` - ISO date when the resource was created

## Usage

### Basic Example

```hcl
module "tags" {
  source = "../../modules/common/tags"

  environment = "sandbox"
  cost_center = "engineering"
}

resource "azurerm_resource_group" "example" {
  name     = "rg-example"
  location = "eastus"
  tags     = module.tags.tags
}
```

### With Custom Tags

```hcl
module "tags" {
  source = "../../modules/common/tags"

  environment = "prod"
  cost_center = "finance"
  
  custom_tags = {
    project     = "customer-portal"
    owner       = "platform-team"
    compliance  = "pci-dss"
  }
}

resource "azurerm_storage_account" "example" {
  name                     = "stexample"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  tags = module.tags.tags
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| environment | Environment name (sandbox, dev, staging, prod) | string | n/a | yes |
| managed_by | Tool or team managing the resource | string | "terraform" | no |
| cost_center | Cost center or department code | string | "engineering" | no |
| custom_tags | Additional custom tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| tags | Merged map of standard and custom tags |
| standard_tags | Standard tags only (before merging) |

## Best Practices

1. **Always use this module** - Don't hardcode tags directly on resources
2. **Custom tags override standard** - If you provide a custom tag with the same key, it takes precedence
3. **Environment validation** - Only valid environments are accepted (sandbox, dev, staging, prod)
4. **Cost center tracking** - Use meaningful cost center codes for accurate billing allocation

## Cost Considerations

**Always Free**: Tags have no cost in Azure. They're metadata only.

