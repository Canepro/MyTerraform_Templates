# Azure Sandbox Stack

A complete Terraform stack demonstrating the usage of common and Azure modules in a safe, cost-conscious sandbox environment.

## 🎯 Perfect for Beginners!

This is your **first deployment** - a safe, free way to learn Terraform and cloud infrastructure!

**What you'll learn:**
- ✅ How to deploy cloud infrastructure with code
- ✅ How to use Terraform modules
- ✅ How to manage cloud resources safely
- ✅ How to clean up when done

**Don't worry!** This guide assumes no prior knowledge. If you get stuck, check the [Getting Started Guide](../../../docs/GETTING_STARTED.md).

## Overview

This stack creates:
- ✅ **Resource Group** (Always Free)
- ✅ **Storage Account** with Standard LRS (Free tier: 5GB)
- ✅ **Virtual Network** with 2 subnets (Always Free)
- ✅ **Service Endpoints** for Storage and Key Vault (Always Free)

**Estimated Cost**: $0.00/month (within free tier limits)

**Time to Deploy**: ~5 minutes  
**Difficulty**: ⭐ Easy

## Architecture

```
rg-<prefix>-sandbox
├── st<prefix>sandbox<suffix>     (Storage Account: Standard LRS)
└── vnet-<prefix>-sandbox-<suffix>
    ├── snet-default              (10.0.1.0/24 with service endpoints)
    └── snet-app                  (10.0.2.0/24 with storage endpoint)
```

## Prerequisites

**Don't have these installed?** Follow the [Getting Started Guide](../../../docs/GETTING_STARTED.md) for step-by-step installation instructions.

### Required Tools

1. **Azure CLI** installed and authenticated:
   ```bash
   az login
   az account show
   ```
   **Need to install?** See [Azure CLI Installation Guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

2. **Terraform** >= 1.5.0:
   ```bash
   terraform version
   ```
   **Need to install?** See [Terraform Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)

3. **Azure Subscription** with appropriate permissions:
   - Contributor or Owner role
   - Ability to create Resource Groups
   - **Don't have one?** Sign up for free at [azure.microsoft.com/free](https://azure.microsoft.com/free)

## Quick Start

**Follow these steps in order!** Each step builds on the previous one.

### Step 1: Clone the Repository

First, get the code onto your computer:

```bash
# Clone the repository
git clone https://github.com/Canepro/MyTerraform_Templates.git

# Navigate into the project
cd MyTerraform_Templates/stacks/azure/sandbox
```

### Step 2: Configure Variables

Copy the example variables file:
```bash
cp terraform.tfvars.example terraform.tfvars
```

**Open `terraform.tfvars` in a text editor** and change the prefix to something unique:

**On Windows:**
```powershell
notepad terraform.tfvars
```

**On Mac/Linux:**
```bash
nano terraform.tfvars
```

Edit it to look like this:
```hcl
prefix      = "myapp"  # Change this to something unique (lowercase, no spaces)
environment = "sandbox"
location    = "eastus"
cost_center = "engineering"
```

**💡 Tip**: Use your name or project name for the prefix. Something like "john" or "mylearningproject" works great!

### Step 3: Initialize Terraform

This downloads the Terraform Azure provider and prepares your directory.

```bash
terraform init
```

**Expected output:**
```
Initializing modules...
Terraform has been successfully initialized!
```

**✅ If you see this, you're ready to proceed!**

### Step 4: Review the Plan

**Always run this before deploying!** It shows what Terraform will create without actually creating it.

```bash
terraform plan
```

**Expected output:**
```
Plan: 3 to add, 0 to change, 0 to destroy.
  + module.resource_group (resource group)
  + module.storage_account (storage account)
  + module.virtual_network (virtual network)

Changes to Outputs:
  + resource_group_name = "rg-myapp-sandbox"
```

**💡 Review carefully**: Make sure it shows 3 resources being created and $0.00 cost!

### Step 5: Deploy Your Infrastructure

**This creates real resources in Azure!** 

```bash
terraform apply
```

**Terraform will ask:**
```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

**Type `yes` and press Enter.**

**Wait 1-2 minutes** - Terraform is creating your resources!

### Step 6: Verify Deployment

**Check that everything worked:**

```bash
# View Terraform outputs
terraform output

# Check resources in Azure Portal
az group list --query "[?name=='rg-myapp-sandbox']"
az storage account list --resource-group rg-myapp-sandbox
az network vnet list --resource-group rg-myapp-sandbox
```

**🎉 Congratulations! You just deployed your first infrastructure with Terraform!**

**Want to see it in the Azure Portal?**
1. Go to [portal.azure.com](https://portal.azure.com)
2. Click "Resource groups"
3. Look for `rg-myapp-sandbox` (or whatever prefix you used)

### Step 7: Clean Up (IMPORTANT!)

**Always destroy resources when you're done** to avoid charges and learn proper cleanup.

```bash
terraform destroy
```

**Terraform will show you what will be deleted:**
```
Plan: 0 to add, 0 to change, 3 to destroy.

Do you really want to destroy all resources?
  Enter a value:
```

**Type `yes` and press Enter.**

**✅ All resources deleted** - No charges incurred!

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

## Common Issues & Troubleshooting

**Getting stuck?** This section covers the most common problems beginners face.

### ❌ Issue: Storage account name already exists

**Error message:**
```
Error: storage account name "stmyappsandbox" is not available
```

**Why this happens:** Storage account names must be globally unique across all Azure customers worldwide.

**Solutions:**
1. **Change your prefix** (easiest):
   ```hcl
   # In terraform.tfvars
   prefix = "myunique123"  # Try your name + numbers
   ```

2. **Add a suffix**:
   ```hcl
   # In terraform.tfvars
   prefix = "myapp"
   suffix = "001"  # Creates stmyapp001sandbox
   ```

3. **Use a random suffix**:
   ```hcl
   # In terraform.tfvars
   prefix = "myapp"
   # Terraform will generate unique suffix
   ```

### ❌ Issue: Insufficient permissions

**Error message:**
```
Error: authorization failed to create resource group
```

**Why this happens:** Your Azure account doesn't have permission to create resources.

**Solutions:**
1. **Check your permissions**:
   ```bash
   az account show
   az role assignment list --assignee $(az account show --query user.name -o tsv)
   ```

2. **Ask your admin** for Contributor or Owner role

3. **If using Azure Free Account**: Check that billing is enabled:
   ```bash
   az account show --query "{Name:name, State:state}"
   ```

### ❌ Issue: Region not available

**Error message:**
```
Error: region not available or quota exceeded
```

**Why this happens:** Some Azure regions have capacity constraints.

**Solutions:**
1. **Use a different region** in terraform.tfvars:
   ```hcl
   location = "eastus"   # Most reliable
   # Or try these:
   # location = "westus2"
   # location = "centralus"
   ```

### ❌ Issue: "Terraform not found"

**Error message:**
```
bash: terraform: command not found
```

**Why this happens:** Terraform isn't installed or not in your PATH.

**Solutions:**
1. **Install Terraform**: See [Getting Started Guide](../../../docs/GETTING_STARTED.md#step-1-install-required-tools)
2. **Verify installation**:
   ```bash
   terraform version
   ```
3. **Restart your terminal** after installation

### ❌ Issue: "Not authenticated with Azure"

**Error message:**
```
Error: authentication failure
```

**Why this happens:** You're not logged into Azure CLI.

**Solutions:**
1. **Log in**:
   ```bash
   az login
   ```

2. **Verify you're logged in**:
   ```bash
   az account show
   ```

3. **If you have multiple subscriptions**, select the right one:
   ```bash
   az account list  # List all subscriptions
   az account set --subscription "Your Subscription Name"
   ```

### ❌ Issue: "Module not found"

**Error message:**
```
Error: module not found
```

**Why this happens:** You didn't run `terraform init` or ran it from wrong directory.

**Solutions:**
1. **Make sure you're in the right directory**:
   ```bash
   pwd
   # Should show: .../stacks/azure/sandbox
   ```

2. **Reinitialize**:
   ```bash
   terraform init
   ```

### ❌ Issue: "Can't apply, resources already exist"

**Error message:**
```
Error: resource already exists
```

**Why this happens:** You deployed before, deleted manually, but state file still thinks resources exist.

**Solutions:**
1. **Import existing resources**:
   ```bash
   terraform import azurerm_resource_group.example /subscriptions/.../resourceGroups/rg-myapp-sandbox
   ```

2. **Or destroy and redeploy** (safest for sandbox):
   ```bash
   # Force destroy even if resources don't exist
   terraform destroy -refresh=false
   
   # Then try apply again
   terraform apply
   ```

3. **Or start fresh**:
   ```bash
   rm terraform.tfstate*
   terraform apply
   ```

### ❌ Issue: "My deployment is taking forever"

**Why this happens:** Some resources take longer to create (VMs, databases).

**What to do:**
1. **Wait** - Terraform shows progress, most resources create in 1-5 minutes
2. **Check Azure Portal** - Resources might be created but Azure still initializing
3. **If stuck 10+ minutes**, cancel with `Ctrl+C` and run:
   ```bash
   terraform refresh  # Check actual state
   terraform plan     # See what still needs to be done
   ```

### ✅ General Troubleshooting Steps

**If nothing above works:**

1. **Read the error message** - It usually tells you exactly what's wrong
2. **Check the logs** - Look at the last 5-10 lines of output
3. **Search for the error** - Copy/paste into Google or [GitHub Issues](../../../issues)
4. **Destroy and retry**:
   ```bash
   terraform destroy  # Clean slate
   terraform apply    # Try again
   ```
5. **Ask for help**: [Open an issue](../../../issues) with your error message

### 📞 Still Need Help?

- [Check Getting Started Guide](../../../docs/GETTING_STARTED.md)
- [Read Tutorials](../TUTORIALS.md)
- [Open a GitHub Issue](../../../issues)
- [Start a Discussion](../../../discussions)

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

