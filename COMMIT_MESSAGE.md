# Commit Message

## Title
fix(azure-vm): Add Azure Provider v3.0+ support and existing RG capability

## Description
Major improvements to Azure VM stack for better compatibility and flexibility in restricted environments.

### Fixed
- **Azure Provider v3.0+ Compatibility**: Replaced deprecated `network_security_group_id` argument with `azurerm_network_interface_security_group_association` resource
  - Resolves "Unsupported argument: network_security_group_id" error
  - Uses modern Azure provider pattern for NSG attachment

- **SSH Key Support**: Clarified Azure VM requirement for RSA SSH keys only
  - Ed25519 and ECDSA keys are not supported by Azure
  - Added validation and troubleshooting guidance
  - Provided key extraction examples from .pem files

### Added
- **Existing Resource Group Support**: New capability to use existing resource groups
  - New variables: `use_existing_resource_group` and `existing_resource_group_name`
  - Conditional resource creation with no hardcoded values
  - Data source integration for existing RG references
  - Local values for flexible resource referencing

- **Helper Tools**:
  - `list_resource_groups.sh`: Script to discover available resource groups
  - Shows name, location, and provides copy-paste ready configuration

### Changed
- **Azure VM Module**: Updated to require Azure Provider v3.0+
- **Stack Configuration**: Made resource group creation conditional
- **All tfvars files**: Added new resource group configuration variables
- **Resource References**: Updated all references to use local values

### Documentation
- **Module README**: Added provider compatibility notice
- **Stack README**: 
  - New "Using an Existing Resource Group" section
  - AuthorizationFailed error troubleshooting
  - RSA SSH key requirement clarifications
  - Helper script usage instructions
- **Beginner Guide**: Added "Common Azure VM Issues" section with solutions
- **Getting Started Guide**: Added "Common Issues & Solutions" section
- **All Azure Docs**: Clarified RSA-only SSH key requirement throughout
- **CHANGELOG**: Comprehensive documentation of all changes

### Impact
- ✅ Works with Azure Provider v3.0+
- ✅ Supports enterprise/training environments with restricted permissions
- ✅ No hardcoded values - fully configurable
- ✅ Backward compatible - defaults to creating new RG
- ✅ Better error messages and troubleshooting guidance

### Testing
- ✅ Tested with existing resource group in restricted Azure environment
- ✅ Verified RSA SSH key authentication
- ✅ Confirmed NSG association working correctly
- ✅ All resources deployed successfully

### Breaking Changes
None - all changes are backward compatible with default behavior.

---

## Files Changed
- modules/azure/virtual-machine/main.tf
- modules/azure/virtual-machine/README.md
- stacks/azure/vm/main.tf
- stacks/azure/vm/variables.tf
- stacks/azure/vm/outputs.tf
- stacks/azure/vm/terraform.tfvars.*
- stacks/azure/vm/README.md
- stacks/azure/vm/list_resource_groups.sh (new)
- docs/BEGINNER_GUIDE.md
- docs/GETTING_STARTED.md
- CHANGELOG.md

## Related Issues
- Fixes: AuthorizationFailed error for users without RG create permissions
- Fixes: Azure Provider v3.0+ NSG attachment deprecation
- Fixes: SSH key validation errors with Ed25519 keys

