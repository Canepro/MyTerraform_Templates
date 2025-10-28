# Stack Development Guidelines

This document outlines the standards and best practices for creating Terraform stacks (deployable root configurations) in this repository.

## Purpose

Stacks are complete, deployable Terraform configurations that:
- Consume modules to create full environments
- Organize resources by cloud provider and environment
- Demonstrate module usage patterns
- Provide ready-to-deploy infrastructure

## Stack Structure

Stacks are organized hierarchically:

```
stacks/
├── azure/
│   ├── sandbox/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── terraform.tfvars.example
│   │   ├── backend.tf.example
│   │   └── README.md
│   ├── dev/
│   └── prod/
├── aws/
└── gcp/
```

### Naming Convention

- **Folders**: `stacks/<cloud>/<environment>/`
- **Files**: Standard Terraform naming (main.tf, variables.tf, outputs.tf)
- **Environments**: `sandbox`, `dev`, `staging`, `prod`

## File Requirements

### main.tf

```hcl
# 1. Terraform and provider configuration
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# 2. Common modules (naming, tags)
module "naming" {
  source = "../../../modules/common/naming"
  
  prefix      = var.prefix
  environment = var.environment
}

module "tags" {
  source = "../../../modules/common/tags"
  
  environment = var.environment
  cost_center = var.cost_center
}

# 3. Infrastructure modules
module "resource_group" {
  source = "../../../modules/azure/resource-group"
  
  name     = module.naming.resource_group
  location = var.location
  tags     = module.tags.tags
}

# 4. Additional resources...
```

**Best Practices**:
- Use relative paths to modules (../../../modules/)
- Group related module calls logically
- Use common modules for consistency (naming, tags)
- Pass outputs between modules as needed

### variables.tf

```hcl
# Environment metadata
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "sandbox"
  
  validation {
    condition     = var.environment == "sandbox"
    error_message = "This stack is for sandbox environment only"
  }
}

# Resource naming
variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "demo"
}

# Azure configuration
variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

# Tagging
variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "engineering"
}

variable "custom_tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
```

**Best Practices**:
- Provide sensible defaults for development
- Validate environment-specific constraints
- Document all variables clearly
- Group variables by purpose

### outputs.tf

```hcl
output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.resource_group.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = module.resource_group.id
}

# ... more outputs
```

**Best Practices**:
- Output key resource identifiers
- Output connection strings/endpoints
- Mark sensitive values appropriately
- Group outputs logically

### terraform.tfvars.example

Provide example variable values:

```hcl
# Example Terraform variables
# Copy this file to terraform.tfvars and customize

prefix      = "myapp"
environment = "sandbox"
location    = "eastus"
cost_center = "engineering"

custom_tags = {
  project = "my-project"
  owner   = "team-name"
}
```

**Best Practices**:
- Include ALL variables with example values
- Add comments explaining choices
- Show both simple and complex configurations
- Never commit actual `terraform.tfvars` file

### backend.tf.example

Provide remote state configuration template:

```hcl
# Remote State Backend Configuration
# Copy this file to backend.tf and customize

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstate<unique>"
    container_name       = "tfstate"
    key                  = "sandbox/terraform.tfstate"
  }
}

# Setup instructions:
# 1. Create backend storage account
# 2. Copy this file to backend.tf
# 3. Update values
# 4. Run: terraform init
```

**Best Practices**:
- Include setup instructions
- Show authentication options
- Warn against committing credentials
- Provide Azure CLI commands for setup

### README.md

Every stack MUST include:

1. **Overview**
   - What does this stack deploy?
   - Cost estimate
   - Architecture diagram (optional)

2. **Prerequisites**
   - Required tools (Terraform, Azure CLI)
   - Authentication requirements
   - Permissions needed

3. **Quick Start**
   ```markdown
   1. Configure variables
   2. Initialize Terraform
   3. Review plan
   4. Deploy
   5. Verify
   ```

4. **Configuration**
   - Variable descriptions
   - Customization examples
   - Common scenarios

5. **Cost Considerations**
   - Free tier usage
   - Cost estimates
   - How to stay within budget

6. **Remote State** (Optional)
   - Backend setup instructions
   - State migration commands

7. **Cleanup**
   - How to destroy resources
   - Verification steps

8. **Troubleshooting**
   - Common issues and solutions

## Environment-Specific Guidelines

### Sandbox Stacks

**Purpose**: Safe, cost-free experimentation

**Requirements**:
- MUST use only free-tier or always-free resources
- MUST enforce `environment = "sandbox"` validation
- MUST include cost warnings if paid resources used
- SHOULD include cost estimates in README

**Example Validation**:
```hcl
variable "environment" {
  validation {
    condition     = var.environment == "sandbox"
    error_message = "This stack is for sandbox environment only"
  }
}
```

**Allowed Resources**:
- ✅ Resource Groups
- ✅ Virtual Networks (no gateways)
- ✅ Storage Accounts (< 5GB)
- ✅ Service Endpoints
- ⚠️ Avoid: VMs, AKS, Databases, Gateways

### Dev Stacks

**Purpose**: Development and testing

**Requirements**:
- Use cost-effective SKUs (B-series VMs, Standard storage)
- Include auto-shutdown for compute resources
- Tag with `environment = "dev"`
- Document estimated costs

### Prod Stacks

**Purpose**: Production workloads

**Requirements**:
- Use production-grade SKUs
- Enable high availability options
- Include backup and DR configuration
- Implement security best practices
- Tag with `environment = "prod"`
- Require manual approval for applies

## Backend Configuration

### Local State (Development)

```hcl
# No backend block = local state
# Suitable for: Personal testing, sandbox
```

### Azure Storage Backend (Recommended)

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstate<env>"
    container_name       = "tfstate"
    key                  = "<cloud>/<environment>/terraform.tfstate"
  }
}
```

**Setup**:
```bash
# Create state storage account
az group create --name rg-terraform-state --location eastus

az storage account create \
  --name sttfstatesandbox \
  --resource-group rg-terraform-state \
  --location eastus \
  --sku Standard_LRS \
  --encryption-services blob

az storage container create \
  --name tfstate \
  --account-name sttfstatesandbox
```

## Deployment Workflow

### 1. Initial Setup

```bash
# Clone repository
git clone <repo-url>
cd stacks/azure/sandbox

# Copy example variables
cp terraform.tfvars.example terraform.tfvars

# Edit variables
vim terraform.tfvars
```

### 2. Initialize

```bash
# Initialize Terraform
terraform init

# If using remote backend
cp backend.tf.example backend.tf
# Edit backend.tf
terraform init
```

### 3. Plan

```bash
# Generate execution plan
terraform plan -out=tfplan

# Review plan carefully
terraform show tfplan
```

### 4. Apply

```bash
# Apply changes
terraform apply tfplan

# Or apply with auto-approve (use carefully)
terraform apply -auto-approve
```

### 5. Verify

```bash
# View outputs
terraform output

# Check in Azure Portal
az resource list --resource-group <rg-name>
```

## Best Practices

### 1. Module Usage

✅ **Do**: Use modules for all resources
```hcl
module "storage_account" {
  source = "../../../modules/azure/storage-account"
  # ...
}
```

❌ **Don't**: Define resources directly in stacks
```hcl
resource "azurerm_storage_account" "this" {
  # This should be in a module
}
```

### 2. Variable Defaults

✅ **Do**: Provide safe defaults for dev/sandbox
```hcl
variable "vm_size" {
  default = "Standard_B1s"  # Cheapest option
}
```

❌ **Don't**: Use expensive defaults
```hcl
variable "vm_size" {
  default = "Standard_D16s_v3"  # Expensive!
}
```

### 3. Cost Transparency

✅ **Do**: Document costs in README
```markdown
## Estimated Costs
- Sandbox: $0.00/month (free tier)
- Dev: ~$50/month
- Prod: ~$500/month
```

❌ **Don't**: Hide cost implications

### 4. Security

✅ **Do**: Use secure defaults
```hcl
allow_public_access = false
enable_https_traffic_only = true
```

❌ **Don't**: Expose resources publicly

### 5. Dependencies

```hcl
# Pass outputs between modules
module "vnet" {
  source = "../../../modules/azure/virtual-network"
  # ...
}

module "vm" {
  source = "../../../modules/azure/virtual-machine"
  
  subnet_id = module.vnet.subnet_ids["default"]
}
```

## Testing Stacks

Before committing:

- [ ] `terraform fmt` applied
- [ ] `terraform validate` passes
- [ ] `terraform plan` succeeds
- [ ] Deployed and tested locally
- [ ] Cost estimate documented
- [ ] README includes all sections
- [ ] Variables have examples
- [ ] Sensitive values not committed

## CI/CD Integration

Stacks integrate with GitHub Actions:

1. **PR Validation**: `terraform fmt`, `validate`, `plan`
2. **Apply**: Only on merge to main (with approval)
3. **Cost Checks**: Optional cost guardrails for sandbox

See `.github/workflows/` for CI/CD configuration.

## Common Patterns

### Multi-Environment

```
stacks/azure/
├── common.tf        # Shared configuration
├── sandbox/
│   └── main.tf      # Uses common.tf
├── dev/
│   └── main.tf
└── prod/
    └── main.tf
```

### Feature Flags

```hcl
variable "enable_monitoring" {
  description = "Enable monitoring stack"
  type        = bool
  default     = false  # Disabled in sandbox
}

module "monitoring" {
  count  = var.enable_monitoring ? 1 : 0
  source = "../../../modules/azure/monitoring"
}
```

## Troubleshooting

### Issue: Module not found

```bash
terraform init  # Re-initialize to fetch modules
```

### Issue: State locked

```bash
# Force unlock (use carefully)
terraform force-unlock <lock-id>
```

### Issue: Name conflicts

```bash
# Use unique prefix or suffix
prefix = "myapp"
suffix = "001"
```

## References

- [Terraform Workspaces](https://www.terraform.io/docs/language/state/workspaces.html)
- [Azure Backend Configuration](https://www.terraform.io/docs/language/settings/backends/azurerm.html)
- [Module Composition](https://www.terraform.io/docs/language/modules/develop/composition.html)

