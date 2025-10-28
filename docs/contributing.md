# Contributing to MyTerraform_Templates

Thank you for your interest in contributing! This document provides guidelines for contributing to this repository.

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on collaboration and learning
- Help maintain a welcoming community

## How to Contribute

### 1. Reporting Issues

**Bug Reports**:
- Use GitHub Issues
- Include clear title and description
- Provide steps to reproduce
- Include Terraform version and provider versions
- Share relevant error messages

**Feature Requests**:
- Describe the use case
- Explain why it's beneficial
- Consider cost implications
- Suggest implementation approach

### 2. Contributing Code

#### Types of Contributions

1. **New Modules**: Add Azure, AWS, or GCP modules
2. **Module Improvements**: Enhance existing modules
3. **New Stacks**: Add example deployments
4. **Documentation**: Improve guides and examples
5. **Bug Fixes**: Fix issues in existing code
6. **CI/CD**: Improve automation workflows

## Development Workflow

### Step 1: Fork and Clone

```bash
# Fork the repository on GitHub
# Clone your fork
git clone https://github.com/<your-username>/MyTerraform_Templates.git
cd MyTerraform_Templates

# Add upstream remote
git remote add upstream https://github.com/<original-owner>/MyTerraform_Templates.git
```

### Step 2: Create a Branch

```bash
# Create feature branch
git checkout -b feature/new-module-name

# Or for bug fixes
git checkout -b fix/issue-description
```

**Branch Naming**:
- `feature/<description>` - New features or modules
- `fix/<description>` - Bug fixes
- `docs/<description>` - Documentation updates
- `refactor/<description>` - Code refactoring

### Step 3: Make Changes

Follow our guidelines:
- [Module Guidelines](./module-guidelines.md) for new modules
- [Stack Guidelines](./stack-guidelines.md) for new stacks

**Code Standards**:
- Use kebab-case for folder names
- Use snake_case for Terraform identifiers
- Follow Terraform style conventions
- Add comprehensive documentation
- Include cost information

### Step 4: Test Your Changes

```bash
# Format code
terraform fmt -recursive

# Validate all modules
cd modules/<cloud>/<your-module>
terraform init -backend=false
terraform validate

# Test stack deployment (optional but recommended)
cd stacks/azure/sandbox
terraform init
terraform plan
```

### Step 5: Commit Changes

```bash
# Stage changes
git add .

# Commit with descriptive message
git commit -m "feat: add storage-account module with cost-safe defaults"
```

**Commit Message Format**:

```
<type>: <short description>

<optional longer description>

<optional footer>
```

**Types**:
- `feat`: New feature or module
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `ci`: CI/CD changes
- `chore`: Maintenance tasks

**Examples**:
```
feat: add Key Vault module with private endpoint support

- Add main.tf with secure defaults
- Include RBAC configuration
- Document cost considerations
- Add usage examples

Closes #42
```

### Step 6: Push and Create PR

```bash
# Push to your fork
git push origin feature/new-module-name

# Create Pull Request on GitHub
```

## Pull Request Process

### PR Template

When creating a PR, include:

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] New module
- [ ] Bug fix
- [ ] Documentation update
- [ ] Stack example
- [ ] CI/CD improvement

## Checklist
- [ ] Code follows style guidelines
- [ ] terraform fmt applied
- [ ] terraform validate passes
- [ ] Documentation updated
- [ ] COST.md or cost section included
- [ ] Tested locally
- [ ] Screenshots/examples added (if applicable)

## Cost Implications
- Free tier: Yes/No
- Estimated cost: $X/month
- Cost warnings added: Yes/No

## Testing
Describe how you tested your changes
```

### Review Process

1. **Automated Checks**: CI/CD runs fmt, validate, and plan
2. **Peer Review**: At least one maintainer reviews
3. **Feedback**: Address comments and suggestions
4. **Approval**: Maintainer approves after review
5. **Merge**: Squash and merge to main

### Review Criteria

Reviewers check for:
- ✅ Code quality and style
- ✅ Documentation completeness
- ✅ Cost transparency
- ✅ Security best practices
- ✅ Test coverage
- ✅ Breaking changes (avoid if possible)

## Module Contribution Guidelines

### Required Files

```
modules/<cloud>/<module-name>/
├── main.tf           # ✅ Required
├── variables.tf      # ✅ Required
├── outputs.tf        # ✅ Required
├── README.md         # ✅ Required
└── COST.md           # ✅ Required (or section in README)
```

### Documentation Requirements

**README.md must include**:
- [ ] Title and purpose
- [ ] Cost category (Always Free / Free Tier / Paid)
- [ ] Basic usage example
- [ ] Advanced usage examples
- [ ] Input variables table
- [ ] Output values table
- [ ] Best practices section
- [ ] References to official docs

**COST.md must include**:
- [ ] Cost category with emoji (✅ free, ⚠️ paid)
- [ ] Cost breakdown table
- [ ] Free tier information (if applicable)
- [ ] Cost optimization strategies
- [ ] Sandbox safety guidance
- [ ] Reference links

### Code Quality

**All modules must**:
- [ ] Use safe, cost-effective defaults
- [ ] Include input validation where appropriate
- [ ] Mark sensitive outputs
- [ ] Follow security best practices
- [ ] Use consistent naming conventions
- [ ] Pass `terraform fmt -check`
- [ ] Pass `terraform validate`

## Stack Contribution Guidelines

### Required Files

```
stacks/<cloud>/<environment>/
├── main.tf                      # ✅ Required
├── variables.tf                 # ✅ Required
├── outputs.tf                   # ✅ Required
├── terraform.tfvars.example     # ✅ Required
├── backend.tf.example           # ✅ Required
└── README.md                    # ✅ Required
```

### Stack Requirements

- [ ] Consumes modules (don't define resources directly)
- [ ] Includes cost estimate in README
- [ ] Provides example variables file
- [ ] Documents prerequisites
- [ ] Includes deployment and cleanup instructions
- [ ] Uses common modules (naming, tags)

## Documentation Contributions

We welcome documentation improvements:

- Fix typos or unclear explanations
- Add examples or use cases
- Improve formatting or structure
- Translate documentation (if applicable)
- Add architecture diagrams

**Process**:
1. Edit markdown files in `docs/` or module READMEs
2. Preview changes locally
3. Submit PR with `docs:` prefix

## CI/CD Contributions

Improve automation workflows:

- Add new validation checks
- Improve cost guardrails
- Enhance PR comments
- Add security scanning
- Optimize workflow performance

**Location**: `.github/workflows/`

## First-Time Contributors

Great first contributions:

1. **Documentation fixes**: Fix typos, improve clarity
2. **Example improvements**: Add usage examples to modules
3. **Cost documentation**: Enhance COST.md files
4. **Simple modules**: Add basic Azure resources (public IP, NSG)
5. **Stack examples**: Create new environment stacks

Look for issues labeled `good-first-issue` or `help-wanted`.

## Getting Help

- **Questions**: Open a GitHub Discussion
- **Issues**: Create a GitHub Issue
- **Chat**: Join our [Discord/Slack] (if applicable)
- **Email**: Contact maintainers (if listed)

## Style Guide

### Terraform Code

```hcl
# Good: Clear variable names, validation, defaults
variable "storage_account_name" {
  description = "Name of the storage account (3-24 chars, lowercase alphanumeric)"
  type        = string
  
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be 3-24 characters, lowercase alphanumeric only"
  }
}

# Good: Use dynamic blocks for optional features
dynamic "blob_properties" {
  for_each = var.enable_blob_versioning ? [1] : []
  content {
    versioning_enabled = true
  }
}

# Good: Clear resource naming
resource "azurerm_storage_account" "this" {
  name = var.storage_account_name
  # ...
}
```

### Documentation

```markdown
# Use clear headings

## Purpose
Clear, concise explanation

## Usage
\`\`\`hcl
# Complete, working example
module "example" {
  source = "../../modules/azure/example"
  
  name = "example"
}
\`\`\`

## Cost
✅ Always Free / ⚠️ Costs Apply

| Component | Cost |
|-----------|------|
| Resource  | $X   |
```

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (specify your license here, e.g., MIT, Apache 2.0).

## Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md (if maintained)
- Mentioned in release notes
- Credited in relevant documentation

## Questions?

If you're unsure about anything:
1. Check existing modules for patterns
2. Review the guidelines documents
3. Ask in a GitHub Issue or Discussion
4. Reach out to maintainers

Thank you for contributing to MyTerraform_Templates! 🚀

