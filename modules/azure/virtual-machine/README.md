# Azure Linux Virtual Machine Module

Provision a sandbox-friendly Azure Linux VM that mirrors the AWS EC2 interface: environment-aware sizing, configurable ingress, static public IP by default, and a 4-hour auto-shutdown helper to control costs.

> **Provider Compatibility**: This module requires Azure Provider v3.0 or higher. It uses the modern `azurerm_network_interface_security_group_association` resource for NSG attachment (replaces deprecated `network_security_group_id` argument).

## Highlights

- ✅ Environment profiles (`dev`, `training`, `prod`) automatically set `vm_size` and OS disk size
- ✅ Choose between Ubuntu 22.04 LTS or Azure Linux (CBL-Mariner) images
- ✅ **Docker & Jenkins installed by default** (can be disabled)
- ✅ Managed NSG opens ports 22/80/8080 by default (customise with `allowed_ports` / `allowed_cidrs`)
- ✅ Standard SKU public IP enabled by default for predictable access (disable for private-only deployments)
- ✅ Auto-shutdown schedule defaults to 4 hours after deployment
- ✅ All resources tagged with `Environment`, `Project`, and `ManagedBy=terraform`
- ✅ SSH-only access; passwords remain disabled

> ℹ️ Amazon Linux images are not published in the Azure marketplace. For parity with AWS, use Ubuntu here; Amazon Linux remains exclusive to the AWS EC2 module.

See [COST.md](./COST.md) for pricing guidance and optimisation tips.

## Quick Start

```hcl
module "training_vm" {
  source = "../../modules/azure/virtual-machine"

  name                = "training-vm-01"
  project             = "terraform-labs"
  environment         = "training"
  resource_group_name = "rg-shared-training"
  location            = "eastus"
  subnet_id           = azurerm_subnet.shared.id

  ssh_public_key = file("~/.ssh/id_ed25519.pub")
  allowed_cidrs  = ["203.0.113.0/24"]
}
```

The example above:

- Launches an Ubuntu 22.04 VM (switch to Azure Linux with `os_distribution = "azure-linux"`)
- Applies the `training` profile (`Standard_B2ms`, 50 GB disk)
- Allocates a static public IP for remote access
- Exposes ports 22/80/8080 only to `203.0.113.0/24`
- Schedules an automatic shutdown roughly four hours after deployment

## Environment Profiles

| Environment | VM Size           | OS Disk | Intended Use            |
|-------------|-------------------|---------|-------------------------|
| `dev`       | `Standard_B1s`    | 30 GB   | Free-tier labs          |
| `training`  | `Standard_B2ms`   | 50 GB   | Classroom workshops     |
| `prod`      | `Standard_D2s_v3` | 100 GB  | Persistent demo setups  |

Override `vm_size` or `os_disk_size_gb` as required—validation enforces disks ≥ 30 GB.

## Adaptive Security Rules

```hcl
allowed_ports = [22, 443]
allowed_cidrs = ["198.51.100.10/32", "10.0.0.0/16"]
```

The module provisions a dedicated Network Security Group (NSG) and attaches it to the NIC. Outbound access stays unrestricted so package updates continue to work.

## Docker & Jenkins (Default Feature)

**Docker and Jenkins are installed by default** on all VMs. Docker and Jenkins are installed separately as native services (Jenkins is NOT running as a Docker container).

### Access Jenkins

After deployment:

```bash
# Get Jenkins URL
terraform output jenkins_url

# Get initial admin password
ssh azureuser@<public-ip> "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
```

- **URL**: `http://<public-ip>:8080`
- **Initial Admin Password**: Located at `/var/lib/jenkins/secrets/initialAdminPassword` on the VM
- Follow the Jenkins setup wizard on first access

### Disable if Not Needed

```hcl
module "minimal_vm" {
  source = "../../modules/azure/virtual-machine"
  
  name                = "minimal-vm"
  project             = "demo"
  environment         = "dev"
  resource_group_name = "rg-demo"
  location            = "eastus"
  subnet_id           = azurerm_subnet.main.id
  ssh_public_key      = file("~/.ssh/id_rsa.pub")
  
  install_docker  = false  # Skip Docker installation
  install_jenkins = false  # Skip Jenkins installation
}
```

**Note**: Jenkins requires Docker, so disabling Docker will also skip Jenkins installation.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name` | VM resource name | string | n/a | ✅ |
| `project` | Project tag value | string | n/a | ✅ |
| `environment` | Environment profile (`dev`, `training`, `prod`) | string | `"training"` | ✅ |
| `resource_group_name` | Resource group for the VM | string | n/a | ✅ |
| `location` | Azure region | string | `"eastus"` | |
| `subnet_id` | Subnet ID for NIC placement | string | n/a | ✅ |
| `ssh_public_key` | SSH public key (OpenSSH format) | string | n/a | ✅ |
| `vm_size` | Override VM size | string | `null` | |
| `os_disk_size_gb` | Override OS disk size (GB) | number | `null` | |
| `os_disk_storage_account_type` | OS disk storage tier | string | `"Standard_LRS"` | |
| `os_distribution` | Base image (`ubuntu`, `azure-linux`) | string | `"ubuntu"` | |
| `admin_username` | SSH admin username | string | `"azureuser"` | |
| `allowed_ports` | TCP ports allowed inbound | list(number) | `[22, 80, 8080]` | |
| `allowed_cidrs` | CIDR blocks allowed inbound | list(string) | `["0.0.0.0/0"]` | |
| `enable_public_ip` | Allocate static public IP | bool | `true` | |
| `enable_managed_identity` | Enable system-assigned identity | bool | `false` | |
| `enable_auto_shutdown` | Turn on auto-shutdown helper | bool | `true` | |
| `auto_shutdown_hours` | Hours before shutdown trigger | number | `4` | |
| `auto_shutdown_timezone` | Timezone for shutdown schedule | string | `"UTC"` | |
| `auto_shutdown_notification_enabled` | Enable email notifications | bool | `false` | |
| `install_docker` | Install Docker on the VM | bool | `true` | |
| `install_jenkins` | Install Jenkins via Docker | bool | `true` | |
| `tags` | Extra tags merged into resources | map(string) | `{}` | |

> Validation snippets:
>
> - `os_disk_size_gb` must be `>= 30` and `<= 2048`.
> - `allowed_ports` entries must be between `1` and `65535`.

## Outputs

| Name | Description |
|------|-------------|
| `id` | VM resource ID |
| `name` | VM name |
| `private_ip_address` | Private NIC IP |
| `public_ip_address` | Static public IP (if enabled) |
| `admin_username` | SSH username |
| `network_interface_id` | NIC resource ID |
| `network_security_group_id` | Managed NSG ID |
| `identity_principal_id` | Managed identity principal (if enabled) |
| `resolved_tags` | Final tag map applied to resources |
| `resolved_vm_size` | Effective VM size after defaults |
| `resolved_os_disk_size_gb` | Effective OS disk size after defaults |
| `docker_installed` | Whether Docker was installed |
| `jenkins_installed` | Whether Jenkins was installed |
| `jenkins_url` | Jenkins web interface URL |
| `jenkins_admin_password` | Jenkins admin password (sensitive) |

## OS Choices

- `ubuntu` (default): Canonical Ubuntu 22.04 LTS, Gen2 image.
- `azure-linux`: Microsoft CBL-Mariner 2.x (“Azure Linux”) for hardened container hosts.

Amazon Linux is not provided on Azure—use Ubuntu for cross-cloud tooling while keeping Amazon Linux on AWS.

## Auto-Shutdown Helper

When `enable_auto_shutdown = true`, an Azure DevTest Labs shutdown schedule is created with `daily_recurrence_time` computed as “now + `auto_shutdown_hours`.” Update or disable the schedule after deployment if you prefer a fixed daily shutdown time.

## Security & Cost Notes

- Restrict `allowed_cidrs` to corporate IP ranges; combine with Azure Bastion for zero-trust entry.
- Disable the public IP in private networks to rely on VPN or Bastion.
- Leave auto-shutdown enabled for training labs; pair with Azure Automation or Functions to auto-start when needed.
- Use managed identities instead of embedding credentials on the VM.

## References

- [Azure VM Pricing](https://azure.microsoft.com/pricing/details/virtual-machines/linux/)
- [Azure VM Sizes](https://learn.microsoft.com/azure/virtual-machines/sizes)
- [Ubuntu on Azure Marketplace](https://azuremarketplace.microsoft.com/marketplace/apps/canonical.0001-com-ubuntu-server-jammy)
- [CBL-Mariner (Azure Linux)](https://learn.microsoft.com/azure/azure-linux/overview)
