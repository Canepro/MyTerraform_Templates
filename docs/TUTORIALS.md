# Tutorials and Learning Paths

Complete collection of tutorials for learning infrastructure as code with Terraform.

## 🎯 Choose Your Learning Path

### 🥇 Absolute Beginner
**Never used Terraform or the cloud? Start here!**

1. [Getting Started Guide](GETTING_STARTED.md) - Your first 10 minutes
2. [Understanding Terraform Basics](#understanding-terraform-basics) - Core concepts
3. [Your First Deployment](#your-first-deployment) - Deploy sandbox infrastructure
4. [Cleanup and Best Practices](#cleanup-and-best-practices) - Safely remove resources

### 🥈 Beginner to Intermediate
**Know the basics? Level up your skills!**

1. [Working with Modules](#working-with-modules) - Reusing code
2. [Managing Variables](#managing-variables) - Configuration management
3. [State Management](#state-management) - Understanding Terraform state
4. [Multi-Environment Deployments](#multi-environment-deployments) - Dev, staging, prod

### 🥉 Intermediate to Advanced
**Comfortable with Terraform? Build production systems!**

1. [Remote State Backends](#remote-state-backends) - Team collaboration
2. [CI/CD Integration](#cicd-integration) - Automated deployments
3. [Cost Optimization](#cost-optimization) - Managing expenses
4. [Security Best Practices](#security-best-practices) - Production hardening

## 📚 Tutorial Collections

### Understanding Terraform Basics

#### What is Infrastructure as Code?
Infrastructure as Code (IaC) means managing your cloud resources using code instead of clicking buttons in a web portal.

**Benefits:**
- ✅ **Repeatable**: Deploy the same thing many times
- ✅ **Version controlled**: Track changes like code
- ✅ **Auditable**: See who changed what and when
- ✅ **Scalable**: Manage 1 or 10,000 resources the same way
- ✅ **Shareable**: Your team can use the same configs

#### Core Terraform Concepts

**1. Resources**
A resource is something you create in the cloud (like a storage account or virtual machine).

```hcl
resource "azurerm_resource_group" "example" {
  name     = "rg-example"
  location = "eastus"
}
```

**2. Modules**
Modules are reusable packages of Terraform code.

```hcl
module "storage_account" {
  source = "../../modules/azure/storage-account"
  
  name                = "mystorage"
  resource_group_name = "rg-example"
  location            = "eastus"
}
```

**3. Variables**
Variables let you customize your deployments.

```hcl
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "sandbox"
}
```

**4. Outputs**
Outputs are values you want to see after deployment.

```hcl
output "storage_account_name" {
  value = module.storage_account.name
}
```

#### Terraform Commands Every Beginner Must Know

**1. `terraform init`**
Initializes your working directory. Downloads providers, modules, and plugins.

```bash
terraform init
```

**2. `terraform validate`**
Checks your configuration for syntax errors.

```bash
terraform validate
# Success! The configuration is valid. ✅
```

**3. `terraform plan`**
Shows what will be created, changed, or destroyed.

```bash
terraform plan
# Terraform will perform the following actions:
# + resource_group.example will be created
# Plan: 1 to add, 0 to change, 0 to destroy.
```

**4. `terraform apply`**
Creates or modifies your infrastructure.

```bash
terraform apply
# Do you want to perform these actions?
# Enter a value: yes
```

**5. `terraform destroy`**
Removes all resources.

```bash
terraform destroy
# Do you really want to destroy all resources?
# Enter a value: yes
```

**⚠️ Important**: Always run `terraform plan` before `terraform apply`!

### Your First Deployment

#### Tutorial: Azure Sandbox Deployment

**Time**: 10 minutes  
**Cost**: $0.00 (completely free!)  
**Difficulty**: ⭐ (Easy)

**What you'll deploy:**
- Resource Group
- Storage Account  
- Virtual Network with 2 subnets

**Steps:**

1. **Prerequisites**
   ```bash
   # Verify Terraform is installed
   terraform --version
   
   # Verify Azure CLI is installed
   az --version
   
   # Log in to Azure
   az login
   ```

2. **Clone and configure**
   ```bash
   git clone https://github.com/Canepro/MyTerraform_Templates.git
   cd MyTerraform_Templates/stacks/azure/sandbox
   
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Customize configuration**
   Edit `terraform.tfvars`:
   ```hcl
   prefix      = "mylearning"  # Make this unique!
   environment = "sandbox"
   location    = "eastus"
   cost_center = "education"
   ```

4. **Deploy**
   ```bash
   terraform init
   terraform plan
   terraform apply  # Type 'yes'
   ```

5. **Verify**
   ```bash
   terraform output
   az resource list --resource-group rg-mylearning-sandbox
   ```

6. **Clean up**
   ```bash
   terraform destroy  # Type 'yes'
   ```

**✅ Success!** You've deployed and destroyed your first infrastructure.

### Cleanup and Best Practices

#### Why Cleanup Matters

**Always destroy resources** when you're done experimenting to:
- ✅ Avoid unexpected charges
- ✅ Learn the full Terraform lifecycle
- ✅ Practice proper cleanup procedures
- ✅ Respect cloud provider resources

#### Cleanup Checklist

Before running `terraform destroy`:

- [ ] Verify you're in the correct directory
- [ ] Review what will be destroyed (`terraform plan -destroy`)
- [ ] Ensure no production data will be lost
- [ ] Make sure you're destroying test/sandbox resources only

#### Safe Cleanup Process

```bash
# Step 1: Review what will be destroyed
terraform plan -destroy

# Step 2: Destroy resources
terraform destroy

# Step 3: Verify cleanup
# For Azure
az group list --query "[?name=='rg-mylearning-sandbox']"
# Should return: [] (empty)

# Step 4: Remove local state files (optional but recommended)
rm terraform.tfstate terraform.tfstate.backup
```

#### Best Practices for Beginners

**1. Start Small**
- Deploy 1-3 resources at first
- Understand what each resource does
- Scale up gradually

**2. Always Plan First**
```bash
# NEVER do this:
terraform apply  # Without planning!

# ALWAYS do this:
terraform plan   # Review first
terraform apply  # Then apply
```

**3. Use Meaningful Names**
```hcl
# ❌ Bad
name = "test"

# ✅ Good
name = "rg-learning-sandbox"
```

**4. Read Error Messages Carefully**
Terraform errors are usually very helpful:
- Line numbers tell you where the problem is
- Error messages explain what's wrong
- Often include suggestions for fixes

**5. Document Your Changes**
```bash
# Add comments to your code
resource "azurerm_resource_group" "example" {
  # This is for learning purposes only
  name     = "rg-example"
  location = "eastus"  # Chosen for cost-effectiveness
}
```

### Working with Modules

#### What are Modules?

Modules are reusable packages of Terraform code. Think of them like functions in programming - you write it once, use it many times.

**Why use modules?**
- ✅ **Don't repeat yourself**: Write once, use everywhere
- ✅ **Consistency**: Same configuration across environments
- ✅ **Testing**: Test once, deploy everywhere
- ✅ **Sharing**: Your team uses the same modules

#### Using Built-in Modules

Our repository includes pre-built modules:

```hcl
module "naming" {
  source = "../../modules/common/naming"
  
  prefix      = "myapp"
  environment = "dev"
}

module "resource_group" {
  source = "../../modules/azure/resource-group"
  
  name     = module.naming.resource_group
  location = "eastus"
}
```

#### Creating Your First Custom Module

**Step 1**: Create module directory
```bash
mkdir modules/my-custom-module
cd modules/my-custom-module
```

**Step 2**: Create module files
```bash
# main.tf - resource definitions
touch main.tf

# variables.tf - input variables
touch variables.tf

# outputs.tf - output values
touch outputs.tf

# README.md - documentation
touch README.md
```

**Step 3**: Write module code

`main.tf`:
```hcl
resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
  
  tags = var.tags
}
```

`variables.tf`:
```hcl
variable "name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default     = {}
}
```

`outputs.tf`:
```hcl
output "id" {
  description = "Resource group ID"
  value       = azurerm_resource_group.this.id
}

output "name" {
  description = "Resource group name"
  value       = azurerm_resource_group.this.name
}
```

**Step 4**: Use your module
```hcl
module "my_rg" {
  source = "../../modules/my-custom-module"
  
  name     = "rg-example"
  location = "eastus"
  
  tags = {
    environment = "dev"
  }
}
```

### Managing Variables

#### Types of Variables

**1. Input Variables**
Values you provide when running Terraform.

`variables.tf`:
```hcl
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "sandbox"
  
  validation {
    condition     = contains(["sandbox", "dev", "prod"], var.environment)
    error_message = "Environment must be sandbox, dev, or prod"
  }
}
```

**2. Local Variables**
Values computed within your configuration.

```hcl
locals {
  location_short = replace(var.location, "/[^a-z0-9]/", "")
  
  tags = {
    environment = var.environment
    managed_by  = "terraform"
    created     = timestamp()
  }
}
```

**3. Output Variables**
Values you want to see after deployment.

```hcl
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.example.name
  sensitive   = false
}

output "connection_string" {
  description = "Database connection string"
  value       = azurerm_storage_account.example.primary_connection_string
  sensitive   = true  # Hides value in output
}
```

#### Variable File Strategy

**terraform.tfvars.example** (checked into git):
```hcl
# Example values - customize these
prefix      = "example"
environment = "sandbox"
location    = "eastus"
```

**terraform.tfvars** (NOT checked into git):
```hcl
# Your actual values
prefix      = "myproject"
environment = "dev"
location    = "westus2"
```

**Using variables:**
```bash
# From file
terraform apply

# Or on command line
terraform apply -var='environment=prod'

# Or with a different file
terraform apply -var-file='production.tfvars'
```

### State Management

#### What is Terraform State?

Terraform keeps track of the resources it created in a state file.

**Local State** (default):
```bash
# State saved in:
terraform.tfstate
```

**Remote State** (recommended for teams):
```bash
# State saved in cloud storage
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate12345"
    container_name       = "tfstate"
    key                  = "dev/terraform.tfstate"
  }
}
```

#### Why State Management Matters

**Benefits of remote state:**
- ✅ **Team collaboration**: Everyone uses the same state
- ✅ **Locking**: Prevents two people deploying at once
- ✅ **Security**: State stored securely in cloud
- ✅ **Backup**: Cloud storage provides redundancy

**When to use local state:**
- ✅ Learning/experimentation
- ✅ Single-person projects
- ✅ Quick testing
- ✅ Tutorials

**When to use remote state:**
- ✅ Team projects
- ✅ Production environments
- ✅ CI/CD pipelines
- ✅ Multiple environments

### Multi-Environment Deployments

#### The Three-Environment Pattern

Most organizations use three environments:

1. **Sandbox**: Free tier, for learning and experimentation
2. **Dev**: Cheap resources, for development and testing
3. **Prod**: Production-grade resources, for real users

#### Organizing Environments

```
stacks/
├── sandbox/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
├── dev/
│   ├── main.tf
│   ├── variables.tf
│   └── terraform.tfvars
└── prod/
    ├── main.tf
    ├── variables.tf
    └── terraform.tfvars
```

#### Using Workspaces

Terraform workspaces let you manage multiple environments:

```bash
# Create workspace
terraform workspace new dev
terraform workspace new prod

# Switch workspace
terraform workspace select dev

# Deploy to current workspace
terraform apply

# List workspaces
terraform workspace list

# Show current workspace
terraform workspace show
```

**⚠️ Warning**: Workspaces share the same configuration. Use separate directories for truly different environments.

### Remote State Backends

#### Why Remote State?

**Problem with local state:**
```bash
# User A deploys
terraform apply  # Creates resources, updates local state

# User B tries to deploy
terraform apply  # Doesn't see User A's changes, creates duplicates!

# Solution: Remote state!
```

#### Setting Up Azure Backend

**Step 1**: Create backend storage
```bash
# Create resource group
az group create --name rg-terraform-state --location eastus

# Create storage account (replace 'mystate12345' with unique name)
az storage account create \
  --name stterraformstate12345 \
  --resource-group rg-terraform-state \
  --location eastus \
  --sku Standard_LRS

# Create container
az storage container create \
  --name tfstate \
  --account-name stterraformstate12345
```

**Step 2**: Configure backend
```hcl
# backend.tf
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate12345"
    container_name       = "tfstate"
    key                  = "sandbox/terraform.tfstate"
  }
}
```

**Step 3**: Initialize
```bash
terraform init -migrate-state
# Migrate existing state? yes
```

#### AWS Backend Configuration

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

#### GCP Backend Configuration

```hcl
terraform {
  backend "gcs" {
    bucket  = "my-terraform-state-bucket"
    prefix  = "terraform/state"
    project = "my-terraform-project"
  }
}
```

### CI/CD Integration

#### Why Automate?

**Manual deployment problems:**
- ❌ Human error
- ❌ Slow process
- ❌ Not repeatable
- ❌ Difficult to track

**Automated deployment benefits:**
- ✅ Consistent deployments
- ✅ Fast execution
- ✅ Auditable history
- ✅ Rollback capability

#### GitHub Actions Example

We already have CI/CD workflows in place!

**`.github/workflows/terraform-pr.yml`**:
```yaml
name: Terraform PR Validation

on:
  pull_request:
    branches:
      - main
    paths:
      - 'stacks/**'
      - 'modules/**'

jobs:
  terraform-validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3
      - run: terraform fmt -check -recursive
      - run: terraform init
      - run: terraform validate
      - run: terraform plan
```

**How to use:**
1. Push changes to a branch
2. Create a Pull Request
3. GitHub automatically runs validation
4. Review the plan output
5. Merge if happy

### Cost Optimization

#### Understanding Cloud Costs

**Three types of resources:**
1. **Always free**: No cost ever (Resource Groups, VNets)
2. **Free tier**: Free up to certain limits (Storage 5GB, VM hours)
3. **Pay-as-you-go**: Costs based on usage (Premium storage, additional compute)

#### Cost-Benefit Analysis

| Resource | Free Option | Paid Option | Cost Difference |
|----------|-------------|-------------|-----------------|
| Storage | Standard LRS (5GB) | Premium LRS | +100% |
| Compute | t2.micro (750 hrs) | t3.medium | +400% |
| Network | Service Endpoints | Private Endpoints | +$7/endpoint |

#### Cost Optimization Strategies

**1. Right-Sizing**
```hcl
# ❌ Too big
instance_type = "m5.large"  # $69/month

# ✅ Right-sized
instance_type = "t3.micro"  # $8/month
```

**2. Auto-Shutdown**
```hcl
# For dev/test environments
resource "azurerm_dev_test_global_vm_shutdown_schedule" "this" {
  location           = var.location
  virtual_machine_id = azurerm_linux_virtual_machine.example.id
  enabled            = true
  
  daily_recurrence_time = "1900"  # Shut down at 7 PM
  timezone              = "Eastern Standard Time"
  
  notification_settings {
    enabled = false
  }
}
```

**3. Spot Instances (AWS)**
```hcl
# Save up to 90% on fault-tolerant workloads
instance_market_options {
  market_type = "spot"
  
  spot_options {
    max_price_percentage_over_lowest_price = 100
    spot_instance_type                     = "one-time"
  }
}
```

### Security Best Practices

#### Five Essential Security Rules

**1. Never Commit Secrets**
```bash
# .gitignore
*.tfvars
terraform.tfstate
terraform.tfstate.backup
*.pem
*.key
```

**2. Use Least Privilege**
```hcl
# ❌ Too permissive
role = "Contributor"

# ✅ Specific permissions
role = "Storage Account Contributor"
```

**3. Enable Encryption**
```hcl
# Encryption enabled by default in our modules
encryption_enabled = true
```

**4. Use Managed Identities**
```hcl
# ❌ Hardcoded credentials
connection_string = "AccountKey=..."

# ✅ Managed identity
identity {
  type = "SystemAssigned"
}
```

**5. Enable Monitoring**
```hcl
# Enable audit logs
logging {
  enabled = true
  retention_days = 30
}
```

## 🎓 Certification Prep

### Microsoft Azure

**AZ-104**: Azure Administrator Associate
- Study: [Azure Learn Modules](https://learn.microsoft.com/en-us/certifications/exams/az-104/)
- Practice: Deploy all Azure modules from this repository
- Test: Use our sandbox stacks for hands-on practice

**AZ-204**: Azure Developer Associate
- Study: [Azure Developer Learning Path](https://learn.microsoft.com/en-us/training/paths/az-204-develop-solutions-microsoft-azure/)
- Practice: Integrate Terraform with Azure DevOps

### Amazon Web Services

**SAA-C03**: Solutions Architect Associate
- Study: [AWS Training](https://aws.amazon.com/training/)
- Practice: Deploy all AWS modules from this repository
- Test: Build multi-tier architectures

**AWS DevOps Engineer**
- Study: [DevOps Learning Path](https://aws.amazon.com/training/learning-paths/devops-engineer/)
- Practice: Set up CI/CD with AWS modules

### Google Cloud Platform

**PCA**: Professional Cloud Architect
- Study: [GCP Training](https://cloud.google.com/training)
- Practice: Deploy all GCP modules from this repository
- Test: Design production architectures

## 🤝 Need Help?

- **Questions**: [GitHub Discussions](../../discussions)
- **Bugs**: [Open an Issue](../../issues)
- **Feature Requests**: [Submit an Idea](../../issues/new)
- **Contributions**: [Contribute Guide](contributing.md)

## 🎉 Practice Challenges

### Challenge 1: Deploy and Destroy ⭐
**Difficulty**: Easy  
**Time**: 15 minutes

Deploy the Azure sandbox three times with different prefixes. Each time, destroy it before redeploying.

### Challenge 2: Custom Module ⭐⭐
**Difficulty**: Medium  
**Time**: 30 minutes

Create a custom module that deploys a Resource Group + Storage Account together.

### Challenge 3: Multi-Environment ⭐⭐⭐
**Difficulty**: Hard  
**Time**: 1 hour

Create separate sandbox, dev, and prod configurations using the same modules but different variables.

### Challenge 4: CI/CD Pipeline ⭐⭐⭐⭐
**Difficulty**: Very Hard  
**Time**: 2 hours

Set up a GitHub Actions workflow that automatically validates and deploys on push to main.

---

**Happy Learning!** 🚀

Remember: Every expert was once a beginner. Keep practicing, keep learning!

