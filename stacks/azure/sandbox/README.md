# Azure Sandbox Stack

A complete Terraform stack demonstrating the usage of common and Azure modules in a safe, cost-conscious sandbox environment.

## Overview

This stack creates:
- ✅ **Resource Group** (Always Free)
- ✅ **Storage Account** with Standard LRS (Free tier: 5GB)
- ✅ **Virtual Network** with 2 subnets (Always Free)
- ✅ **Service Endpoints** for Storage and Key Vault (Always Free)

**Estimated Cost**: $0.00/month (within free tier limits)

## Architecture

```
rg-<prefix>-sandbox
├── st<prefix>sandbox<suffix>     (Storage Account: Standard LRS)
└── vnet-<prefix>-sandbox-<suffix>
    ├── snet-default              (10.0.1.0/24 with service endpoints)
    └── snet-app                  (10.0.2.0/24 with storage endpoint)
```

## Prerequisites

1. **Azure CLI** installed and authenticated:
   ```bash
   az login
   az account show
   ```

2. **Terraform** >= 1.5.0:
   ```bash
   terraform version
   ```

3. **Azure Subscription** with appropriate permissions:
   - Contributor or Owner role
   - Ability to create Resource Groups

## Quick Start

### 1. Configure Variables

Copy the example variables file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
prefix      = "myapp"
environment = "sandbox"
location    = "eastus"
cost_center = "engineering"
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Review the Plan

```bash
terraform plan
```

Expected output: **3 modules to add** (resource group, storage, vnet)

### 4. Deploy

```bash
terraform apply
```

Type `yes` when prompted.

### 5. Verify Deployment

```bash
# View outputs
terraform output

# Check resources in Azure
az group list --query "[?name=='rg-myapp-sandbox']"
az storage account list --resource-group rg-myapp-sandbox
az network vnet list --resource-group rg-myapp-sandbox
```

## Configuration

### Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| prefix | Resource name prefix | "demo" | No |
| environment | Environment (must be "sandbox") | "sandbox" | No |
| suffix | Optional suffix | "" | No |
| location | Azure region | "eastus" | No |
| cost_center | Cost center code | "engineering" | No |
| vnet_address_space | VNet CIDR range | ["10.0.0.0/16"] | No |

### Customization Examples

**Multiple sandbox instances**:
```hcl
# terraform.tfvars
prefix = "myapp"
suffix = "001"  # Creates rg-myapp-sandbox-001
```

**Different region**:
```hcl
location = "westus2"  # Choose closer region
```

**Custom network**:
```hcl
vnet_address_space    = ["192.168.0.0/16"]
subnet_default_prefix = "192.168.1.0/24"
subnet_app_prefix     = "192.168.2.0/24"
```

## Cost Considerations

### Free Tier Usage

This stack stays within Azure free tier:
- ✅ Resource Group: Always free
- ✅ Storage Account: Free for first 5GB
- ✅ Virtual Network: Always free
- ✅ Subnets: Always free

### Staying Free

To avoid charges:
1. **Storage**: Keep data under 5GB
2. **Egress**: Limit downloads to 5GB/month
3. **No Gateways**: Don't add VPN/NAT gateways
4. **No Premium**: Stick with Standard tier

### Cost Alerts

Set up cost alerts in Azure:
```bash
az consumption budget create \
  --name sandbox-budget \
  --resource-group rg-myapp-sandbox \
  --amount 5 \
  --time-grain Monthly
```

## Remote State (Optional)

For team collaboration, configure remote state:

1. Create backend storage (one-time):
   ```bash
   az group create --name rg-terraform-state --location eastus
   
   az storage account create \
     --name sttfstatesandbox \
     --resource-group rg-terraform-state \
     --location eastus \
     --sku Standard_LRS
   
   az storage container create \
     --name tfstate \
     --account-name sttfstatesandbox
   ```

2. Configure backend:
   ```bash
   cp backend.tf.example backend.tf
   # Edit backend.tf with your storage account details
   terraform init -migrate-state
   ```

## Cleanup

To destroy all resources:

```bash
# Review what will be destroyed
terraform plan -destroy

# Destroy resources
terraform destroy
```

Type `yes` when prompted.

**Verify cleanup**:
```bash
az group list --query "[?name=='rg-myapp-sandbox']"
```

## Outputs

After deployment, access outputs:

```bash
# View all outputs
terraform output

# Specific outputs
terraform output resource_group_name
terraform output storage_account_name
terraform output virtual_network_id
```

## Common Issues

### Issue: Storage account name already exists

Storage account names must be globally unique. Solutions:
- Change the `prefix` variable
- Add a `suffix` variable
- Use a more unique prefix

### Issue: Insufficient permissions

Ensure your Azure account has:
- Contributor or Owner role
- Permission to create Resource Groups
- Run: `az role assignment list --assignee $(az account show --query user.name -o tsv)`

### Issue: Region not available

Some regions have capacity constraints. Try:
- eastus
- westus2
- centralus

## Next Steps

1. **Add Resources**: Explore other Azure modules (Key Vault, AKS, etc.)
2. **CI/CD**: Set up GitHub Actions for automated deployments
3. **Environments**: Create dev/prod stacks based on this example
4. **Policies**: Add Azure Policy for governance

## References

- [Azure Free Account](https://azure.microsoft.com/en-us/free/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Naming Conventions](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)

## Support

For issues or questions:
1. Check module READMEs in `modules/azure/`
2. Review COST.md files for cost guidance
3. See `docs/` for guidelines
4. Open an issue in the repository

