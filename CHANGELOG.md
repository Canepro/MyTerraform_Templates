# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Azure VM Stack**: Support for using existing resource groups
  - New variables: `use_existing_resource_group` and `existing_resource_group_name`
  - Conditional resource creation based on user permissions
  - Helper script `list_resource_groups.sh` to discover available resource groups
  - Useful for enterprise/training environments with restricted permissions

### Fixed
- **Azure Virtual Machine Module**: Fixed compatibility with Azure Provider v3.0+ by replacing deprecated `network_security_group_id` argument with `azurerm_network_interface_security_group_association` resource
  - This resolves the "Unsupported argument: network_security_group_id" error
  - Module now properly associates NSG to network interface using the modern Azure provider pattern
- **SSH Key Validation**: Clarified that Azure VMs only support RSA SSH keys (Ed25519 and ECDSA not supported)

### Changed
- **Azure Virtual Machine Module**: Updated to require Azure Provider v3.0 or higher
  - Uses modern `azurerm_network_interface_security_group_association` resource for NSG attachment
  - Improves compatibility with latest Azure provider versions
- **Azure VM Stack**: Made resource group creation conditional
  - Can now use existing resource groups or create new ones
  - All resource references updated to use local values for flexibility

### Documentation
- **Module README**: Added provider compatibility notice for Azure Virtual Machine module
- **Stack README**: Comprehensive updates including:
  - New section on using existing resource groups
  - Troubleshooting for AuthorizationFailed errors
  - SSH key validation errors, including RSA-only requirement
  - Helper script documentation
- **Beginner Guide**: Added "Common Azure VM Issues" section with solutions for:
  - Network security group compatibility issues
  - SSH key decoding errors (including Ed25519 not supported)
  - Terraform initialization failures
  - How to extract public keys from existing .pem files
- **Getting Started Guide**: Added "Common Issues & Solutions" section covering Azure, AWS, and general Terraform issues
- **All Azure documentation**: Clarified that Azure VMs only support RSA SSH keys (Ed25519 and ECDSA are not supported)
- **Helper Script**: Created `list_resource_groups.sh` to help users discover available resource groups

## [1.0.0] - 2025-11-11

### Added
- Initial repository structure
- Azure modules: Resource Group, Storage Account, Virtual Network, Key Vault, Virtual Machine, AKS Cluster, App Service, Container Apps
- AWS modules: S3 Bucket, VPC, IAM User, EC2 Instance
- GCP modules: Storage Bucket, VPC, Service Account
- Common modules: Naming, Tags
- Azure sandbox stack
- AWS sandbox stack
- GCP sandbox stack
- Complete beginner documentation and tutorials
- Multi-cloud deployment guides
- CI/CD workflows for validation and deployment

[Unreleased]: https://github.com/Canepro/MyTerraform_Templates/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/Canepro/MyTerraform_Templates/releases/tag/v1.0.0

