# Azure Storage Account Module

A Terraform module for creating Azure Storage Accounts with cost-safe defaults and security best practices.

## Purpose

Azure Storage Accounts provide:
- **Blob Storage**: Object storage for unstructured data
- **File Storage**: Fully managed file shares
- **Queue Storage**: Message queuing for application workflows
- **Table Storage**: NoSQL key-value store

## Cost

**Pay-as-you-go with free tier available** ⚠️

- First 5 GB of LRS blob storage is free per month
- First 5 GB of egress is free per month
- Storage starts at ~$0.018/GB for Hot LRS
- Transactions and operations have minimal costs

See [COST.md](./COST.md) for detailed cost information.

## Default Configuration (Cost-Safe)

This module uses the most cost-effective defaults:
- **Tier**: Standard (cheapest, sufficient for most workloads)
- **Replication**: LRS (Locally Redundant, lowest cost)
- **Access Tier**: Hot (for frequently accessed data)
- **Security**: HTTPS-only, TLS 1.2 minimum, no public blob access
- **Advanced Features**: Versioning and change feed disabled by default

## Usage

### Basic Example

```hcl
module "storage_account" {
  source = "../../modules/azure/storage-account"

  name                = "stmyappsandbox001"
  resource_group_name = "rg-myapp-sandbox"
  location            = "eastus"
  
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

module "storage_account" {
  source = "../../modules/azure/storage-account"

  name                = module.naming.storage_account
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = module.tags.tags
}
```

### Geo-Redundant Storage (Higher Cost)

```hcl
module "storage_account_geo" {
  source = "../../modules/azure/storage-account"

  name                     = "stmyappprodgeo"
  resource_group_name      = "rg-myapp-prod"
  location                 = "eastus"
  account_replication_type = "GRS"  # Geo-redundant (3x cost of LRS)
  
  tags = {
    environment = "prod"
    criticality = "high"
  }
}
```

### Cool Access Tier (Archive/Backup)

```hcl
module "storage_account_cool" {
  source = "../../modules/azure/storage-account"

  name                = "stmyappbackup"
  resource_group_name = "rg-myapp-prod"
  location            = "eastus"
  access_tier         = "Cool"  # Lower storage cost, higher access cost
  
  tags = {
    purpose = "backup"
  }
}
```

### With Soft Delete and Versioning

```hcl
module "storage_account_protected" {
  source = "../../modules/azure/storage-account"

  name                                = "stmyappproddata"
  resource_group_name                 = "rg-myapp-prod"
  location                            = "eastus"
  
  enable_blob_versioning              = true
  blob_soft_delete_retention_days     = 30
  container_soft_delete_retention_days = 7
  
  tags = {
    environment = "prod"
    protection  = "enabled"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Storage account name (3-24 chars, lowercase alphanumeric) | string | n/a | yes |
| resource_group_name | Resource group name | string | n/a | yes |
| location | Azure region | string | "eastus" | no |
| account_tier | Standard or Premium | string | "Standard" | no |
| account_replication_type | LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS | string | "LRS" | no |
| account_kind | Storage account kind | string | "StorageV2" | no |
| access_tier | Hot or Cool | string | "Hot" | no |
| allow_public_access | Allow public blob access | bool | false | no |
| enable_blob_versioning | Enable blob versioning | bool | false | no |
| blob_soft_delete_retention_days | Soft delete retention (0 = disabled) | number | 0 | no |
| tags | Resource tags | map(string) | {} | no |

## Outputs

| Name | Description | Sensitive |
|------|-------------|-----------|
| id | Storage account ID | No |
| name | Storage account name | No |
| primary_blob_endpoint | Blob endpoint URL | No |
| primary_access_key | Primary access key | Yes |
| primary_connection_string | Connection string | Yes |

## Replication Types and Costs

| Type | Description | Relative Cost | Use Case |
|------|-------------|---------------|----------|
| LRS | Locally Redundant (3 copies in 1 datacenter) | 1x | Dev/test, non-critical data |
| ZRS | Zone Redundant (3 availability zones) | 1.25x | Production, higher availability |
| GRS | Geo-Redundant (6 copies, 2 regions) | 2x | Business continuity |
| GZRS | Geo + Zone Redundant | 2.5x | Mission-critical |

## Best Practices

1. **Use LRS for dev/sandbox** - Lowest cost, sufficient for testing
2. **Enable soft delete in production** - Protect against accidental deletion
3. **Disable public access** - Use private endpoints or SAS tokens
4. **Use Cool tier for archives** - 50% cheaper storage, higher retrieval cost
5. **Monitor egress** - First 5GB free, then ~$0.087/GB

## Security Features

- HTTPS-only traffic enforced
- TLS 1.2 minimum version
- Public blob access disabled by default
- Network access can be restricted
- Supports Azure AD authentication

## Limitations

- Storage account names must be globally unique across all of Azure
- Name restrictions: 3-24 characters, lowercase alphanumeric only
- Cannot change account kind after creation (some exceptions)
- Premium tier only supports specific storage types

## References

- [Azure Storage Pricing](https://azure.microsoft.com/en-us/pricing/details/storage/)
- [Storage Account Overview](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-overview)
- [Storage Security Guide](https://learn.microsoft.com/en-us/azure/storage/common/storage-security-guide)

