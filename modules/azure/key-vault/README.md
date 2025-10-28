# Azure Key Vault Module

A Terraform module for creating Azure Key Vaults with RBAC-based access control, soft delete protection, and network security.

## Purpose

Azure Key Vault securely stores and manages:
- **Secrets**: Connection strings, passwords, API keys
- **Keys**: Cryptographic keys for encryption
- **Certificates**: SSL/TLS certificates

## Cost

**Free Tier Available** ⚠️

- **Free**: First 10,000 operations/month per vault
- **Paid**: $0.03 per 10,000 operations after free tier
- **Premium SKU**: Adds HSM-backed keys (~$1/month per key)

See [COST.md](./COST.md) for detailed cost information.

## Features

- ✅ **RBAC-based access** (no legacy access policies)
- ✅ **Soft delete** enabled (7-90 days retention)
- ✅ **Network ACLs** for IP/subnet restrictions
- ✅ **Audit logging** ready
- ✅ **Integration** with VMs, Disk Encryption, ARM templates

## How to Use

### Basic Example

```hcl
module "key_vault" {
  source = "../../modules/azure/key-vault"

  name                = "kv-myapp-sandbox"
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

module "key_vault" {
  source = "../../modules/azure/key-vault"

  name                = module.naming.key_vault
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = module.tags.tags
}
```

### With Network Restrictions

```hcl
module "key_vault_secure" {
  source = "../../modules/azure/key-vault"

  name                = "kv-myapp-prod"
  resource_group_name = "rg-myapp-prod"
  location            = "eastus"
  
  # Lock down network access
  network_acls_default_action = "Deny"
  network_acls_ip_rules       = ["203.0.113.0/24"]
  network_acls_subnet_ids     = [azurerm_subnet.private.id]
  
  # Enable purge protection for production
  purge_protection_enabled = true
  
  tags = {
    environment = "prod"
    criticality = "high"
  }
}
```

### Grant RBAC Access

After creating the Key Vault, assign roles to users/service principals:

```bash
# Get the Key Vault ID
vault_id=$(terraform output -raw key_vault_id)

# Grant "Key Vault Administrator" role
az role assignment create \
  --role "Key Vault Administrator" \
  --assignee user@example.com \
  --scope "$vault_id"

# Or "Key Vault Secrets User" for read-only secret access
az role assignment create \
  --role "Key Vault Secrets User" \
  --assignee <service-principal-id> \
  --scope "$vault_id"
```

Common RBAC roles:
- `Key Vault Administrator` - Full access
- `Key Vault Secrets Officer` - Manage secrets
- `Key Vault Secrets User` - Read secrets
- `Key Vault Certificates Officer` - Manage certificates
- `Key Vault Crypto Officer` - Manage keys

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Key Vault name (3-24 chars) | string | n/a | yes |
| resource_group_name | Resource group name | string | n/a | yes |
| location | Azure region | string | "eastus" | no |
| sku_name | standard or premium | string | "standard" | no |
| soft_delete_retention_days | Retention days (7-90) | number | 7 | no |
| purge_protection_enabled | Enable purge protection | bool | false | no |
| enabled_for_deployment | Allow VM certificate retrieval | bool | false | no |
| enabled_for_disk_encryption | Allow disk encryption | bool | false | no |
| enabled_for_template_deployment | Allow ARM template access | bool | false | no |
| network_acls_default_action | Allow or Deny | string | "Allow" | no |
| network_acls_ip_rules | Allowed IP addresses | list(string) | [] | no |
| network_acls_subnet_ids | Allowed subnet IDs | list(string) | [] | no |
| tags | Resource tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Key Vault ID |
| name | Key Vault name |
| vault_uri | Key Vault URI (e.g., https://kv-myapp.vault.azure.net/) |
| tenant_id | Azure AD tenant ID |
| location | Key Vault location |

## RBAC Authorization

This module uses **RBAC authorization** (not legacy access policies). Benefits:
- ✅ Centralized identity management
- ✅ Audit logs via Azure AD
- ✅ Fine-grained permissions
- ✅ Consistent with Azure best practices

To use the Key Vault, users/apps need appropriate RBAC role assignments.

## Best Practices

1. **Use RBAC roles** - Assign least-privilege roles
2. **Enable soft delete** - Prevent accidental permanent deletion (enabled by default)
3. **Network restrictions** - Use `Deny` default for production
4. **Purge protection** - Enable for production vaults
5. **Audit logs** - Send to Log Analytics or Storage Account
6. **Name uniquely** - Key Vault names must be globally unique

## Security Features

- ✅ **Soft delete**: 7-90 day retention before permanent deletion
- ✅ **Purge protection**: Prevents permanent deletion even by admins
- ✅ **Network ACLs**: Restrict access by IP/subnet
- ✅ **RBAC**: Azure AD-based access control
- ✅ **Audit logs**: All operations logged

## Limitations

- Key Vault names must be globally unique
- Maximum 24 characters (alphanumeric and hyphens)
- Soft delete retention minimum 7 days
- Network ACLs require Allow or Deny all traffic (no partial allow)

## Common Use Cases

### Storing Application Secrets

```hcl
# Create secret (after vault is created)
resource "azurerm_key_vault_secret" "db_password" {
  name         = "database-password"
  value        = random_password.db.result
  key_vault_id = module.key_vault.id
}
```

### Retrieving Secrets in Applications

```bash
# Azure CLI
az keyvault secret show \
  --name database-password \
  --vault-name kv-myapp-prod \
  --query value -o tsv

# Azure SDK (Python)
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient

credential = DefaultAzureCredential()
client = SecretClient(vault_url="https://kv-myapp-prod.vault.azure.net/", credential=credential)
secret = client.get_secret("database-password")
print(secret.value)
```

## References

- [Azure Key Vault Overview](https://learn.microsoft.com/en-us/azure/key-vault/general/overview)
- [Key Vault Pricing](https://azure.microsoft.com/en-us/pricing/details/key-vault/)
- [RBAC Roles](https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide)
- [Best Practices](https://learn.microsoft.com/en-us/azure/key-vault/general/best-practices)

