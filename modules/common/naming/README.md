# Common Naming Module

This module generates consistent Azure resource names following Microsoft's Cloud Adoption Framework (CAF) naming conventions.

## Purpose

- Enforce consistent naming patterns across all resources
- Follow Azure best practices and abbreviations
- Handle resource-specific naming constraints (length, character sets)
- Reduce naming errors and improve resource organization

## Naming Convention

The module uses the following pattern:

```
<resource-type-abbreviation>-<prefix>-<environment>-<suffix>
```

**Examples:**
- `rg-myapp-sandbox-001` (Resource Group)
- `vnet-myapp-dev-hub` (Virtual Network)
- `stmyappprod` (Storage Account - no hyphens, lowercase)
- `aks-myapp-prod-cluster` (AKS Cluster)

## Resource Type Abbreviations

Following [Microsoft CAF standards](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations):

| Resource Type | Abbreviation | Example |
|---------------|--------------|---------|
| Resource Group | rg | rg-myapp-sandbox |
| Storage Account | st | stmyappsandbox |
| Virtual Network | vnet | vnet-myapp-dev |
| Subnet | snet | snet-myapp-prod-web |
| Network Security Group | nsg | nsg-myapp-prod |
| Public IP | pip | pip-myapp-dev |
| Key Vault | kv | kvmyappprod |
| AKS Cluster | aks | aks-myapp-prod |
| Container Registry | acr | acrmyappprod |
| App Service | app | app-myapp-prod |

## Usage

### Basic Example

```hcl
module "naming" {
  source = "../../modules/common/naming"

  prefix      = "myapp"
  environment = "sandbox"
}

resource "azurerm_resource_group" "example" {
  name     = module.naming.resource_group
  location = "eastus"
}

resource "azurerm_storage_account" "example" {
  name                     = module.naming.storage_account
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
```

### With Suffix

```hcl
module "naming_web" {
  source = "../../modules/common/naming"

  prefix      = "myapp"
  environment = "prod"
  suffix      = "web"
}

module "naming_data" {
  source = "../../modules/common/naming"

  prefix      = "myapp"
  environment = "prod"
  suffix      = "data"
}

resource "azurerm_virtual_network" "web" {
  name                = module.naming_web.virtual_network  # vnet-myapp-prod-web
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_virtual_network" "data" {
  name                = module.naming_data.virtual_network  # vnet-myapp-prod-data
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.1.0.0/16"]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| prefix | Prefix for resource names (app/project name) | string | n/a | yes |
| environment | Environment name (sandbox, dev, staging, prod) | string | n/a | yes |
| suffix | Optional suffix (e.g., 001, web, data) | string | "" | no |

### Input Validation

- **prefix**: 2-10 characters, lowercase alphanumeric only
- **environment**: Must be one of: sandbox, dev, staging, prod
- **suffix**: Empty or 1-6 characters, lowercase alphanumeric only

## Outputs

The module outputs generated names for all common Azure resource types:

| Output | Description |
|--------|-------------|
| resource_group | Resource Group name |
| storage_account | Storage Account name (truncated to 24 chars) |
| virtual_network | Virtual Network name |
| subnet | Subnet name |
| key_vault | Key Vault name (truncated to 24 chars) |
| aks_cluster | AKS cluster name |
| container_registry | Container Registry name (alphanumeric only) |

...and many more (see `outputs.tf` for the complete list).

## Special Handling

### Storage Accounts & Key Vaults
- No hyphens allowed
- Lowercase only
- Maximum 24 characters
- Module automatically truncates and formats

### Container Registry
- Alphanumeric only (no hyphens)
- Maximum 50 characters

## Best Practices

1. **Use consistent prefixes** - Choose a short, meaningful project/app name
2. **Follow environment naming** - Stick to: sandbox, dev, staging, prod
3. **Use suffixes for multiples** - When creating multiple resources of the same type (e.g., web, data, 001, 002)
4. **Don't override module names** - Let the module handle naming constraints

## Cost Considerations

**Always Free**: Naming conventions have no cost impact. They only improve organization and management.

