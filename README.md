# MyTerraform_Templates

A collection of reusable, cost-conscious Terraform modules and example stacks for Azure, AWS, and GCP, with an Azure-first focus.

## 🚀 New to Terraform? Start Here!

**Never used Terraform or cloud infrastructure?** Follow these guides:

- 📖 **[Getting Started Guide for Absolute Beginners](docs/GETTING_STARTED.md)** - Your first 10 minutes with Terraform
- 🎓 **[Complete Tutorials Collection](docs/TUTORIALS.md)** - Step-by-step learning paths
- 🌍 **[AWS Setup Guide](docs/aws-setup-guide.md)** - Complete AWS account setup and deployment
- ☁️ **[GCP Setup Guide](docs/gcp-setup-guide.md)** - Complete GCP account setup and deployment

**Already know Terraform?** Jump to [Quick Start](#quick-start) below.

## Overview

This repository provides:
- **Reusable Modules**: Small, focused Terraform modules following best practices
- **Example Stacks**: Complete, deployable infrastructure configurations
- **Cost Transparency**: Every module includes cost information (✅ free, ⚠️ paid)
- **Security Defaults**: Secure configurations out-of-the-box
- **CI/CD Integration**: GitHub Actions workflows for validation and deployment
- **Beginner-Friendly**: Complete guides and tutorials for absolute beginners

**Primary Focus**: Azure (with AWS and GCP support for multi-cloud scenarios)

## Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.5.0
- Cloud provider CLI installed:
  - **Azure**: [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
  - **AWS**: [AWS CLI](https://aws.amazon.com/cli/)
  - **GCP**: [Google Cloud SDK](https://cloud.google.com/sdk)
- Cloud account with appropriate permissions

### Choose Your Platform

#### 🎯 Azure (Recommended for beginners)

Perfect for new users with a generous free tier:

```bash
# Clone the repository
git clone https://github.com/Canepro/MyTerraform_Templates.git
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

**📚 Complete Setup Guide**: [Azure Setup Instructions](stacks/azure/sandbox/README.md)  
**💰 Estimated Cost**: $0.00/month (within free tier) ✅

#### 🌍 AWS

For building on the largest cloud ecosystem:

```bash
# Clone the repository
git clone https://github.com/Canepro/MyTerraform_Templates.git
cd MyTerraform_Templates

# Set up AWS credentials
aws configure
# Enter your Access Key ID, Secret Access Key, and region

# Create a stack (see examples in modules/aws/)
terraform init
terraform plan
terraform apply
```

**📚 Complete Setup Guide**: [AWS Setup Instructions](docs/aws-setup-guide.md)  
**💰 Estimated Cost**: $0.00/month (with free tier) ✅

#### ☁️ Google Cloud Platform

For data analytics and machine learning:

```bash
# Clone the repository
git clone https://github.com/Canepro/MyTerraform_Templates.git
cd MyTerraform_Templates

# Set up GCP authentication
export GOOGLE_APPLICATION_CREDENTIALS="path/to/credentials.json"
gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS

# Create a stack (see examples in modules/gcp/)
terraform init
terraform plan
terraform apply
```

**📚 Complete Setup Guide**: [GCP Setup Instructions](docs/gcp-setup-guide.md)  
**💰 Estimated Cost**: $0.00/month (with $300 free credit) ✅

### Need Help?

**New to Terraform?**
- 📖 [Getting Started Guide](docs/GETTING_STARTED.md) - Complete beginner tutorial
- 🎓 [Tutorials Collection](docs/TUTORIALS.md) - Step-by-step learning paths

**Platform-Specific Help**
- **Azure**: [Sandbox Stack README](stacks/azure/sandbox/README.md) | [Account Setup Guide](docs/GETTING_STARTED.md#azure-beginner-guide-recommended)
- **AWS**: [AWS Setup Guide](docs/aws-setup-guide.md) | [Account Setup Guide](docs/GETTING_STARTED.md#aws-beginner-guide)
- **GCP**: [GCP Setup Guide](docs/gcp-setup-guide.md) | [Account Setup Guide](docs/GETTING_STARTED.md#gcp-beginner-guide)

**For Developers**
- 📘 [Module Guidelines](docs/module-guidelines.md) - Create new modules
- 📗 [Stack Guidelines](docs/stack-guidelines.md) - Build deployments
- 🤝 [Contributing Guide](docs/contributing.md) - Contribute to the project

**Get Help**
- 💬 [Ask a Question](../../discussions) - Community help
- 🐛 [Report a Bug](../../issues/new) - Found an issue?
- 💡 [Request a Feature](../../issues/new) - Suggest improvements

## Repository Structure

```
MyTerraform_Templates/
├── .github/workflows/           # CI/CD automation (fmt, validate, plan, apply)
├── modules/                     # Reusable Terraform modules
│   ├── common/                 # Shared utilities (naming, tags)
│   ├── azure/                  # Azure-specific modules (8 modules)
│   ├── aws/                    # AWS modules (5+ modules)
│   └── gcp/                    # GCP modules (3 modules)
├── stacks/                      # Deployable root configurations
│   ├── azure/
│   │   └── sandbox/            # Safe, cost-free sandbox environment ✅
│   ├── aws/                    # AWS stacks (coming soon)
│   └── gcp/                    # GCP stacks (coming soon)
├── docs/                        # Documentation and guidelines
│   ├── GETTING_STARTED.md      # 📖 Beginner's first deployment guide 🆕
│   ├── TUTORIALS.md            # 🎓 Complete tutorials collection 🆕
│   ├── aws-setup-guide.md      # Complete AWS account & deployment guide
│   ├── gcp-setup-guide.md      # Complete GCP account & deployment guide
│   ├── module-guidelines.md    # Standards for creating modules
│   ├── stack-guidelines.md     # Standards for creating stacks
│   └── contributing.md         # Contribution guidelines
└── README.md                    # This file
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
| [key-vault](modules/azure/key-vault/) | Key Vault with RBAC authorization | ⚠️ Free tier (10K ops) |
| [virtual-machine](modules/azure/virtual-machine/) | Linux VMs with SSH and auto-shutdown | ⚠️ ~$9/month (B1s) |
| [aks-cluster](modules/azure/aks-cluster/) | Kubernetes cluster with Azure CNI | ⚠️⚠️ ~$73/month |
| [app-service](modules/azure/app-service/) | Linux App Service with F1 free tier | ✅ Free tier (10 apps) |
| [container-apps](modules/azure/container-apps/) | Serverless containers with scale-to-zero | ✅ Free tier (180K vCPU-s) |

### AWS Modules

| Module | Description | Cost | Status |
|--------|-------------|------|--------|
| [s3-bucket](modules/aws/s3-bucket/) | S3 bucket with encryption and versioning | ⚠️ Free tier (5GB) | ✅ Ready |
| [vpc](modules/aws/vpc/) | VPC with public/private subnets | ✅ Always Free | ✅ Ready |
| [iam-user](modules/aws/iam-user/) | IAM user with policy attachments | ✅ Always Free | ✅ Ready |
| [ec2-instance](modules/aws/ec2-instance/) | EC2 instances with security defaults | ⚠️ ~$8/month | ✅ Ready |
| [ecs-cluster](modules/aws/ecs-cluster/) | ECS cluster for containers | Coming Soon | 🚧 Q1 2026 |
| [eks-cluster](modules/aws/eks-cluster/) | Kubernetes cluster | Coming Soon | 🚧 Q1 2026 |
| [lambda-function](modules/aws/lambda-function/) | Serverless functions | ⚠️ Free tier (1M requests) | 🚧 Q1 2026 |
| [rds-instance](modules/aws/rds-instance/) | Managed databases | ⚠️ ~$15/month | 🚧 Q1 2026 |
| [secrets-manager](modules/aws/secrets-manager/) | Secrets management | ⚠️ ~$0.40/secret | 🚧 Q1 2026 |

### GCP Modules

| Module | Description | Cost |
|--------|-------------|------|
| [storage-bucket](modules/gcp/storage-bucket/) | Cloud Storage bucket | ⚠️ Free tier (5GB) |
| [vpc](modules/gcp/vpc/) | VPC with custom subnets | ✅ Always Free |
| [service-account](modules/gcp/service-account/) | Service account with IAM roles | ✅ Always Free |

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

## 🗺️ Learning Path for Beginners

**New to Terraform and cloud infrastructure?** Follow this roadmap:

### Week 1: Foundation ⭐
- [ ] Complete [Getting Started Guide](docs/GETTING_STARTED.md)
- [ ] Deploy the Azure sandbox successfully
- [ ] Understand what `terraform init`, `plan`, `apply`, `destroy` do
- [ ] Deploy and destroy 5 times to get comfortable

### Week 2: Core Concepts ⭐⭐
- [ ] Work through [Tutorials](docs/TUTORIALS.md)
- [ ] Deploy individual modules (Resource Group, Storage Account, VNet)
- [ ] Learn to read and modify Terraform configuration
- [ ] Practice troubleshooting common errors

### Week 3: Real Projects ⭐⭐⭐
- [ ] Deploy a virtual machine
- [ ] Set up SSH access to your VM
- [ ] Deploy a complete VPC with public and private subnets
- [ ] Create your first custom module

### Week 4: Best Practices ⭐⭐⭐⭐
- [ ] Set up remote state backend
- [ ] Configure different environments (dev/prod)
- [ ] Learn about state management
- [ ] Set up basic CI/CD

### Month 2: Advanced Topics 🚀
- [ ] Multi-cloud deployments (Azure + AWS)
- [ ] Security hardening
- [ ] Cost optimization strategies
- [ ] Certification prep (AZ-104, SAA-C03, PCA)

**Need help at any step?** Check [Tutorials](docs/TUTORIALS.md) or [Ask for Help](../../discussions).

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
- [x] Azure modules (RG, Storage, VNet, Key Vault, AKS, VMs, App Service, Container Apps)
- [x] AWS modules (S3, VPC, IAM User)
- [x] GCP modules (Storage, VPC, Service Account)
- [x] Sandbox stack example
- [x] CI/CD workflows
- [x] Documentation

### Next (Q1 2026)
- [ ] Dev and prod stacks
- [ ] Cost policy enforcement in CI
- [ ] Module versioning with Git tags
- [ ] Additional AWS modules (EC2, RDS, Lambda)
- [ ] Additional GCP modules (Compute Engine, Cloud SQL)

### Future
- [ ] Multi-cloud stacks
- [ ] Terraform Cloud integration
- [ ] Policy as Code (Sentinel/OPA)
- [ ] Infrastructure testing (Terratest)
- [ ] Advanced monitoring and alerting modules

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
- [Registry](https://registry.terraform.io/)

### Cloud Providers

#### Azure
- [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/)
- [Azure Free Account](https://azure.microsoft.com/en-us/free/)
- [Azure Architecture Center](https://learn.microsoft.com/en-us/azure/architecture/)
- [Cloud Adoption Framework](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/)
- [Azure Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

#### AWS
- [AWS Pricing Calculator](https://calculator.aws/)
- [AWS Free Tier](https://aws.amazon.com/free/)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [AWS Architecture Center](https://aws.amazon.com/architecture/)
- [AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

#### GCP
- [GCP Pricing Calculator](https://cloud.google.com/products/calculator)
- [GCP Free Tier](https://cloud.google.com/free/docs/gcp-free-tier)
- [GCP Well-Architected Framework](https://cloud.google.com/architecture/framework)
- [GCP Architecture Center](https://cloud.google.com/architecture)
- [GCP Provider Docs](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

### Cost Management
- [Azure Cost Management](https://azure.microsoft.com/en-us/services/cost-management/)
- [AWS Cost Management](https://aws.amazon.com/aws-cost-management/)
- [GCP Cost Management](https://cloud.google.com/cost-management)
- [Multi-Cloud Cost Optimization](https://www.tensult.com/blogs/cloud-cost-optimization-strategies/)

## License

MIT License - Copyright (c) 2025 Canepro

## Maintainers

- [@Canepro](https://github.com/Canepro)

## Acknowledgments

- Microsoft Azure for comprehensive documentation
- HashiCorp for Terraform
- Open source community for inspiration and best practices

---

**Happy Terraforming!** 🚀

For questions or feedback, please [open an issue](../../issues) or [start a discussion](../../discussions).

