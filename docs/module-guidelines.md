# Module Development Guidelines

This document outlines the standards and best practices for creating Terraform modules in this repository.

## Purpose

These guidelines ensure:
- Consistency across all modules
- Clear documentation and usage examples
- Cost transparency
- Security best practices
- Maintainability and testability

## Module Structure

Every module MUST follow this structure:

```
modules/<cloud>/<module-name>/
├── main.tf           # Primary resource definitions
├── variables.tf      # Input variables with validation
├── outputs.tf        # Output values
├── README.md         # Documentation with examples
├── COST.md           # Cost information (or section in README)
└── versions.tf       # (Optional) Provider version constraints
```

### Naming Convention

- **Folders**: Use kebab-case (e.g., `storage-account`, `virtual-network`)
- **Resources**: Use snake_case (e.g., `azurerm_storage_account`)
- **Variables**: Use snake_case (e.g., `resource_group_name`)
- **Outputs**: Use snake_case (e.g., `primary_blob_endpoint`)

## File Requirements

### main.tf

```hcl
# 1. Terraform and provider version constraints
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# 2. Resource definitions
resource "azurerm_resource" "this" {
  # Use "this" as the resource name for single-resource modules
  name = var.name
  # ... other attributes
}

# 3. Use dynamic blocks for optional features
dynamic "blob_properties" {
  for_each = var.enable_blob_versioning ? [1] : []
  content {
    versioning_enabled = true
  }
}
```

**Best Practices**:
- Pin provider versions for stability (`~> 3.0`)
- Use `this` as the resource name for simplicity
- Group related resources logically
- Use dynamic blocks for optional features
- Add comments for complex logic

### variables.tf

```hcl
variable "name" {
  description = "Clear, concise description of the variable"
  type        = string
  
  # Add validation rules where appropriate
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name))
    error_message = "Name must contain only lowercase letters, numbers, and hyphens"
  }
}

variable "optional_setting" {
  description = "Description including the default behavior"
  type        = string
  default     = "safe-default-value"
}

variable "complex_object" {
  description = "Description with structure explanation"
  type = object({
    name  = string
    value = number
  })
  default = null
}
```

**Best Practices**:
- Always provide clear descriptions
- Add validation rules for format requirements
- Use safe defaults that won't incur costs
- Document default behavior in descriptions
- Use appropriate types (string, number, bool, list, map, object)
- Mark optional variables with `optional()` in Terraform 1.3+

### outputs.tf

```hcl
output "id" {
  description = "The ID of the resource"
  value       = azurerm_resource.this.id
}

output "sensitive_value" {
  description = "Sensitive value (e.g., access key)"
  value       = azurerm_resource.this.primary_key
  sensitive   = true
}
```

**Best Practices**:
- Always include descriptions
- Mark sensitive values with `sensitive = true`
- Output common identifiers (ID, name, location)
- Output connection strings and endpoints
- Use descriptive names

### README.md

Every module MUST include:

1. **Title and Purpose**
   - What does the module do?
   - Why would you use it?

2. **Cost Information**
   - Always Free / Free Tier / Paid
   - Link to COST.md or inline cost section
   - Emoji indicators: ✅ (free), ⚠️ (costs apply)

3. **Usage Examples**
   - Basic example (minimum required inputs)
   - Advanced examples (with optional features)
   - Integration with common modules (naming, tags)

4. **Inputs Table**
   ```markdown
   | Name | Description | Type | Default | Required |
   |------|-------------|------|---------|----------|
   ```

5. **Outputs Table**
   ```markdown
   | Name | Description |
   |------|-------------|
   ```

6. **Best Practices**
   - Module-specific recommendations
   - Security considerations
   - Cost optimization tips

7. **References**
   - Official Azure/AWS/GCP documentation
   - Pricing pages
   - Relevant blog posts or guides

### COST.md

Every module MUST include cost information, either as:
- Separate `COST.md` file (recommended for complex pricing)
- Cost section in `README.md` (for simple cases)

**Structure**:

```markdown
# Cost Information: <Module Name>

## Cost Category: **[Always Free / Free Tier / Paid]** [Emoji]

Brief summary of cost implications.

## Cost Breakdown

| Component | Cost |
|-----------|------|

## Free Tier (if applicable)

What's included in free tier?

## Cost Optimization Strategies

### For Sandbox/Development
- Safe, free-tier configuration examples

### For Production
- Cost estimates for typical workloads

## Cost Safety for Sandbox

✅ Safe if...
⚠️ Costs may occur if...

## References

- [Official Pricing Page]
```

## Module Best Practices

### 1. Safe Defaults

Always default to the most cost-effective, secure options:

```hcl
variable "account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"  # Cheaper than Premium
}

variable "account_replication_type" {
  description = "Replication type"
  type        = string
  default     = "LRS"  # Cheapest option
}

variable "allow_public_access" {
  description = "Allow public blob access"
  type        = bool
  default     = false  # Secure by default
}
```

### 2. Security Defaults

```hcl
# Enforce HTTPS
enable_https_traffic_only = true

# Minimum TLS version
min_tls_version = "TLS1_2"

# Disable public access by default
allow_nested_items_to_be_public = false
```

### 3. Tagging

All resources should accept and apply tags:

```hcl
variable "tags" {
  description = "Tags to apply to the resource"
  type        = map(string)
  default     = {}
}

resource "azurerm_resource" "this" {
  # ... other attributes
  tags = var.tags
}
```

### 4. Naming

Accept names as input, don't generate them in modules:

```hcl
variable "name" {
  description = "Name of the resource"
  type        = string
}

# Let consumers use the naming module
# module "naming" { ... }
# module "resource" {
#   name = module.naming.resource_name
# }
```

### 5. Dependencies

Minimize dependencies between modules:
- Accept IDs/names as variables
- Don't create resources in multiple modules
- Use data sources for lookups

### 6. Validation

Add validation for:
- Name formats
- CIDR ranges
- Enum values
- Resource limits

```hcl
validation {
  condition     = contains(["sandbox", "dev", "prod"], var.environment)
  error_message = "Environment must be sandbox, dev, or prod"
}
```

## Testing Checklist

Before submitting a module:

- [ ] All required files present (main.tf, variables.tf, outputs.tf, README.md, COST.md)
- [ ] Follows naming conventions (kebab-case folders, snake_case variables)
- [ ] Safe, cost-effective defaults
- [ ] Security best practices applied
- [ ] Input validation added
- [ ] Sensitive outputs marked
- [ ] README includes usage examples
- [ ] COST.md or cost section present
- [ ] Terraform fmt applied
- [ ] Terraform validate passes
- [ ] Successfully tested locally

## Common Patterns

### Optional Feature Flags

```hcl
variable "enable_feature" {
  description = "Enable optional feature"
  type        = bool
  default     = false
}

dynamic "feature_block" {
  for_each = var.enable_feature ? [1] : []
  content {
    # Feature configuration
  }
}
```

### Lists of Objects

```hcl
variable "subnets" {
  description = "List of subnets to create"
  type = list(object({
    name             = string
    address_prefixes = list(string)
  }))
  default = []
}

resource "azurerm_subnet" "this" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }
  
  name             = each.value.name
  address_prefixes = each.value.address_prefixes
}
```

## Anti-Patterns (Avoid)

❌ **Hardcoded values**:
```hcl
location = "eastus"  # Use variable instead
```

❌ **Generating names in modules**:
```hcl
name = "${var.prefix}-${var.environment}-rg"  # Use naming module
```

❌ **Insecure defaults**:
```hcl
allow_public_access = true  # Should default to false
```

❌ **Costly defaults**:
```hcl
account_replication_type = "GRS"  # Use LRS for sandbox
```

❌ **Missing validation**:
```hcl
variable "environment" {
  type = string
  # Should validate allowed values
}
```

## Version Management

When updating modules:

1. **Backward Compatibility**: Avoid breaking changes
2. **Deprecation**: Mark old variables as deprecated with warnings
3. **Changelog**: Document changes in module README
4. **Versioning**: Use Git tags for module versions (v1.0.0)

## Getting Help

- Review existing modules in `modules/azure/` for examples
- Check Azure provider documentation
- Ask in repository discussions or issues
- Refer to Terraform best practices guide

## References

- [Terraform Module Guidelines](https://www.terraform.io/docs/language/modules/develop/index.html)
- [Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

