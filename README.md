# MyTerraform_Templates

A collection of reusable, cost-conscious Terraform modules and example stacks for Azure, AWS, and GCP, with an Azure-first focus.

## Overview

This repository provides:
- **Reusable Modules**: Small, focused Terraform modules following best practices
- **Example Stacks**: Complete, deployable infrastructure configurations
- **Cost Transparency**: Every module includes cost information (✅ free, ⚠️ paid)
- **Security Defaults**: Secure configurations out-of-the-box
- **CI/CD Integration**: GitHub Actions workflows for validation and deployment

**Primary Focus**: Azure (with AWS and GCP support for multi-cloud scenarios)

## Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.5.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (for Azure resources)
- Azure subscription with appropriate permissions

### Deploy the Sandbox Stack

```bash
# Clone the repository
git clone <repo-url>
cd MyTerraform_Templates/stacks/azure/sandbox

# Configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# Authenticate with Azure
az login

# Initialize and deploy
terraform init
terraform plan
terraform apply
```

**Estimated Cost**: $0.00/month (within free tier) ✅

See the [Sandbox Stack README](stacks/azure/sandbox/README.md) for detailed instructions.

## Repository Structure

```
MyTerraform_Templates/
├── .github/workflows/      # CI/CD automation (fmt, validate, plan, apply)
├── modules/                # Reusable Terraform modules
│   ├── common/            # Shared utilities (naming, tags)
│   ├── azure/             # Azure-specific modules
│   ├── aws/               # AWS modules (future)
│   └── gcp/               # GCP modules (future)
├── stacks/                # Deployable root configurations
│   ├── azure/
│   │   └── sandbox/       # Safe, cost-free sandbox environment
│   ├── aws/               # AWS stacks (future)
│   └── gcp/               # GCP stacks (future)
├── docs/                  # Documentation and guidelines
│   ├── module-guidelines.md
│   ├── stack-guidelines.md
│   └── contributing.md
└── README.md              # This file
```

## Available Modules

### Common Utilities

| Module | Description | Cost |
|--------|-------------|------|
| [naming](modules/common/naming/) | Consistent naming conventions for resources | ✅ Free |
| [tags](modules/common/tags/) | Standard tagging strategy | ✅ Free |

### Azure Modules

| Module | Description | Cost |
|--------|-------------|------|
| [resource-group](modules/azure/resource-group/) | Azure Resource Groups | ✅ Always Free |
| [storage-account](modules/azure/storage-account/) | Storage Accounts with safe defaults | ⚠️ Free tier (5GB) |
| [virtual-network](modules/azure/virtual-network/) | VNets with subnets and service endpoints | ✅ Always Free |

**Coming Soon**: Key Vault, AKS, Virtual Machines, App Service, and more!

### AWS Modules

*Coming soon* - Placeholders ready for contribution

### GCP Modules

*Coming soon* - Placeholders ready for contribution

## Example Stacks

### Azure

| Stack | Description | Cost | Status |
|-------|-------------|------|--------|
| [sandbox](stacks/azure/sandbox/) | Safe sandbox with RG, Storage, VNet | ✅ $0.00 | ✅ Ready |
| dev | Development environment | Coming Soon | 🚧 |
| prod | Production environment | Coming Soon | 🚧 |

## Cost Philosophy

This repository follows a **cost-conscious approach**:

1. **Always-Free First**: Prefer resources with no cost
2. **Free Tier Awareness**: Use resources within free tier limits
3. **Safe Defaults**: Modules default to cheapest options (LRS, Standard tier)
4. **Cost Transparency**: Every module includes `COST.md` or cost documentation
5. **Sandbox Safety**: Sandbox stacks use only free-tier resources

### Cost Categories

- ✅ **Always Free**: No cost under any usage (Resource Groups, VNets)
- ✅ **Free Tier**: Free within limits (Storage: 5GB, Egress: 5GB/month)
- ⚠️ **Pay-as-you-go**: Costs based on usage (VMs, AKS, Databases)

## Usage Examples

### Basic Module Usage

```hcl
module "resource_group" {
  source = "../../modules/azure/resource-group"

  name     = "rg-myapp-sandbox"
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

module "storage_account" {
  source = "../../modules/azure/storage-account"

  name                = module.naming.storage_account
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = module.tags.tags
}
```

See individual module READMEs for more examples.

## CI/CD Integration

This repository includes GitHub Actions workflows for:

### Pull Request Validation
- ✅ Format check (`terraform fmt`)
- ✅ Validation (`terraform validate`)
- ✅ Plan generation with PR comments
- ✅ Module validation

Workflow: [`.github/workflows/terraform-pr.yml`](.github/workflows/terraform-pr.yml)

### Deployment
- ✅ Automatic apply on merge to `main`
- ✅ Manual approval gates
- ✅ Plan artifacts
- ✅ Output capture

Workflow: [`.github/workflows/terraform-apply.yml`](.github/workflows/terraform-apply.yml)

### Documentation
- ✅ Auto-generate module documentation
- ✅ Keep docs in sync with code

Workflow: [`.github/workflows/terraform-docs.yml`](.github/workflows/terraform-docs.yml)

### Setup GitHub Secrets

For CI/CD to work, configure these secrets:

```bash
# Azure Service Principal credentials
AZURE_CLIENT_ID
AZURE_CLIENT_SECRET
AZURE_SUBSCRIPTION_ID
AZURE_TENANT_ID

# Or use AZURE_CREDENTIALS (for azure/login action)
AZURE_CREDENTIALS='{"clientId":"...","clientSecret":"...","subscriptionId":"...","tenantId":"..."}'
```

## Documentation

### For Module Developers
📖 [Module Guidelines](docs/module-guidelines.md) - Standards for creating new modules

**Covers**:
- Module structure and file requirements
- Naming conventions
- Variable and output patterns
- Cost documentation requirements
- Security best practices
- Testing checklist

### For Stack Developers
📖 [Stack Guidelines](docs/stack-guidelines.md) - Best practices for creating stacks

**Covers**:
- Stack organization by environment
- Backend configuration
- Variable management
- Cost estimation
- Deployment workflows

### For Contributors
📖 [Contributing Guide](docs/contributing.md) - How to contribute to this project

**Covers**:
- Development workflow
- Pull request process
- Code review criteria
- Documentation standards
- First-time contributor suggestions

## Development Workflow

### 1. Format Code

```bash
terraform fmt -recursive
```

### 2. Validate Modules

```bash
cd modules/azure/<module-name>
terraform init -backend=false
terraform validate
```

### 3. Test Stack

```bash
cd stacks/azure/sandbox
terraform init
terraform plan
```

### 4. Submit PR

```bash
git checkout -b feature/new-module
git add .
git commit -m "feat: add new module"
git push origin feature/new-module
```

## Best Practices

### Module Design
- ✅ Single responsibility (one module = one resource type)
- ✅ Safe, cost-effective defaults
- ✅ Input validation with clear error messages
- ✅ Comprehensive documentation with examples
- ✅ Cost transparency (COST.md)

### Stack Design
- ✅ Use modules (don't define resources directly)
- ✅ Organize by environment (sandbox, dev, prod)
- ✅ Use common modules for consistency
- ✅ Include example variable files
- ✅ Document prerequisites and costs

### Security
- ✅ HTTPS-only for storage and endpoints
- ✅ Disable public access by default
- ✅ Use managed identities when possible
- ✅ Mark sensitive outputs
- ✅ Follow principle of least privilege

### Cost Management
- ✅ Use LRS for storage (cheapest)
- ✅ Choose Standard tier over Premium
- ✅ Enable auto-shutdown for VMs (dev/test)
- ✅ Monitor usage with Azure Cost Management
- ✅ Set up budget alerts

## Roadmap

### Current (Q4 2025)
- [x] Repository structure
- [x] Common modules (naming, tags)
- [x] Basic Azure modules (RG, Storage, VNet)
- [x] Sandbox stack example
- [x] CI/CD workflows
- [x] Documentation

### Next (Q1 2026)
- [ ] Additional Azure modules (Key Vault, AKS, VMs)
- [ ] Dev and prod stacks
- [ ] Cost policy enforcement in CI
- [ ] Module versioning with Git tags
- [ ] AWS modules (S3, VPC, EC2)

### Future
- [ ] GCP modules (Storage, VPC, Compute)
- [ ] Multi-cloud stacks
- [ ] Terraform Cloud integration
- [ ] Policy as Code (Sentinel/OPA)
- [ ] Infrastructure testing (Terratest)

## Support and Community

### Getting Help
- 📖 Check module READMEs and COST.md files
- 📖 Review [documentation](docs/)
- 🐛 [Open an issue](../../issues) for bugs
- 💡 [Start a discussion](../../discussions) for questions
- 🤝 Read the [contributing guide](docs/contributing.md)

### Contributing
Contributions are welcome! Whether you're:
- Adding new modules
- Improving documentation
- Fixing bugs
- Sharing use cases
- Suggesting features

See [CONTRIBUTING.md](docs/contributing.md) for guidelines.

## Resources

### Terraform
- [Terraform Documentation](https://www.terraform.io/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [Azure Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

### Azure
- [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/)
- [Azure Free Account](https://azure.microsoft.com/en-us/free/)
- [Azure Architecture Center](https://learn.microsoft.com/en-us/azure/architecture/)
- [Cloud Adoption Framework](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/)

### Cost Management
- [Azure Cost Management](https://azure.microsoft.com/en-us/services/cost-management/)
- [Azure Pricing](https://azure.microsoft.com/en-us/pricing/)
- [Cost Optimization Guidance](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/cost-mgt-best-practices)

## License

[Specify your license here - e.g., MIT, Apache 2.0]

## Maintainers

[List maintainers here]

## Acknowledgments

- Microsoft Azure for comprehensive documentation
- HashiCorp for Terraform
- Open source community for inspiration and best practices

---

**Happy Terraforming!** 🚀

For questions or feedback, please [open an issue](../../issues) or [start a discussion](../../discussions).

