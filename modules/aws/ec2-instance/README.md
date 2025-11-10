# AWS EC2 Instance Module

Provision a cost-conscious, sandbox-friendly EC2 instance that reuses the default VPC, enforces secure network access, and self-terminates after four hours unless overridden.

## Highlights

- ✅ Environment profiles (`dev`, `training`, `prod`) pick sensible instance types and disk sizes automatically
- ✅ Choose between the latest Amazon Linux 2023 or Ubuntu 22.04 LTS images
- ✅ **Docker & Jenkins installed by default** (can be disabled)
- ✅ Uses the account's default VPC and public subnet when none are supplied
- ✅ Managed security group with configurable `allowed_ports` (defaults: 22, 80, 8080)
- ✅ Elastic IP enabled by default for static access
- ✅ Auto-shutdown helper schedules a halt after 4 hours (configurable/disable-able)
- ✅ All resources tagged with `Environment`, `Project`, and `ManagedBy=terraform`
- ✅ IMDSv2, EBS encryption, and safe defaults baked in

See [COST.md](./COST.md) for an in-depth breakdown and optimization tips.

## Quick Start

```hcl
module "training_vm" {
  source = "../../modules/aws/ec2-instance"

  name        = "training-vm-01"
  project     = "terraform-labs"
  environment = "training"
  key_name    = "my-ssh-key"

  allowed_cidrs = ["203.0.113.0/24"]
}
```

The example above:

- Launches an Amazon Linux 2023 VM in the default VPC (switch to Ubuntu 22.04 with `os_distribution = "ubuntu"`).
- Uses the `training` profile (`t3.medium`, 50GB gp3).
- Opens ports 22/80/8080 only to `203.0.113.0/24`.
- Schedules an automatic shutdown in four hours and assigns an Elastic IP.

## Environment Profiles

| Environment | Instance Type | Root Volume Size | Intended Use            |
|-------------|---------------|------------------|-------------------------|
| `dev`       | `t3.micro`    | 30 GB            | Free-tier friendly labs |
| `training`  | `t3.medium`   | 50 GB            | Classroom workshops     |
| `prod`      | `t3.large`    | 100 GB           | Stable demo workloads   |

Override `instance_type` or `root_volume_size` when you need something different; keep in mind the validation rules (`>= 30 GB`).

## Advanced Usage

### Custom AMI and Security Groups

```hcl
module "prod_vm" {
  source = "../../modules/aws/ec2-instance"

  name        = "prod-app-01"
  project     = "customer-portal"
  environment = "prod"
  os_distribution = "ubuntu"

  use_latest_ami = false
  ami_id         = "ami-0c55b159cbfafe1f0"

  vpc_id    = aws_vpc.shared.id
  subnet_id = aws_subnet.shared_public.id

  allowed_ports = [22, 443]
  allowed_cidrs = ["198.51.100.10/32"]

  additional_security_group_ids = [aws_security_group.shared.id]

  iam_instance_profile         = aws_iam_instance_profile.ec2.name
  enable_auto_shutdown         = false
  enable_detailed_monitoring   = true
  enable_termination_protection = true
}
```

### Append Custom User Data

```hcl
module "lab_vm" {
  source = "../../modules/aws/ec2-instance"

  name        = "lab-tools"
  project     = "devx"
  environment = "dev"
  key_name    = "lab-key"

  user_data = <<-EOT
    yum install -y git
    echo "Welcome to the lab" > /etc/motd
  EOT
}
```

User-provided `user_data` is appended after the auto-shutdown helper. Disable the helper via `enable_auto_shutdown = false` if you need full control.

## Docker & Jenkins (Default Feature)

**Docker and Jenkins are installed by default** on all VMs. Docker and Jenkins are installed separately as native services (Jenkins is NOT running as a Docker container).

### Access Jenkins

After deployment:

```bash
# Get Jenkins URL
terraform output jenkins_url

# Get initial admin password
ssh -i ~/.ssh/your-key.pem ubuntu@<public-ip> "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
```

- **URL**: `http://<public-ip>:8080`
- **Initial Admin Password**: Located at `/var/lib/jenkins/secrets/initialAdminPassword` on the VM
- Follow the Jenkins setup wizard on first access

### Disable if Not Needed

```hcl
module "minimal_vm" {
  source = "../../modules/aws/ec2-instance"
  
  name        = "minimal-vm"
  project     = "demo"
  environment = "dev"
  key_name    = "my-key"
  
  install_docker  = false  # Skip Docker installation
  install_jenkins = false  # Skip Jenkins installation
}
```

**Note**: Jenkins requires Docker, so disabling Docker will also skip Jenkins installation.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `name` | Name (tag) for the instance | string | n/a | ✅ |
| `project` | Project tag value | string | n/a | ✅ |
| `environment` | Environment profile (`dev`, `training`, `prod`) | string | `"training"` | ✅ |
| `use_latest_ami` | Use the latest AMI for the selected `os_distribution` | bool | `true` | |
| `ami_id` | Specific AMI to use when `use_latest_ami` is `false` | string | `null` | |
| `os_distribution` | Operating system (`amazon-linux`, `ubuntu`) | string | `"amazon-linux"` | |
| `instance_type` | Override instance type | string | `null` | |
| `root_volume_size` | Override root volume size (GB) | number | `null` | |
| `root_volume_type` | EBS volume type | string | `"gp3"` | |
| `vpc_id` | Custom VPC ID (defaults to account default) | string | `null` | |
| `subnet_id` | Custom subnet ID (defaults to public subnet in resolved VPC) | string | `null` | |
| `availability_zone` | AZ hint when auto-selecting a default subnet | string | `null` | |
| `allowed_ports` | TCP ports allowed inbound | list(number) | `[22, 80, 8080]` | |
| `allowed_cidrs` | CIDR blocks permitted inbound | list(string) | `["0.0.0.0/0"]` | |
| `additional_security_group_ids` | Extra security groups to attach | list(string) | `[]` | |
| `enable_eip` | Allocate and attach an Elastic IP | bool | `true` | |
| `key_name` | EC2 key pair name | string | `null` | |
| `iam_instance_profile` | IAM instance profile name | string | `null` | |
| `enable_detailed_monitoring` | Enable CloudWatch detailed monitoring | bool | `false` | |
| `enable_auto_shutdown` | Enable the 4-hour auto shutdown helper | bool | `true` | |
| `auto_shutdown_hours` | Hours before issuing a shutdown | number | `4` | |
| `user_data` | Additional user data appended after the helper script | string | `null` | |
| `enable_termination_protection` | Protect against accidental termination | bool | `false` | |
| `install_docker` | Install Docker on the VM | bool | `true` | |
| `install_jenkins` | Install Jenkins via Docker | bool | `true` | |
| `tags` | Additional tags merged into all resources | map(string) | `{}` | |

> Validation snippets:
>
> - `root_volume_size` must be `>= 30` and `<= 16384`.
> - `allowed_ports` must be between `1` and `65535`.

## Outputs

| Name | Description |
|------|-------------|
| `instance_id` | EC2 instance ID |
| `instance_arn` | EC2 instance ARN |
| `private_ip` | Private IP address |
| `public_ip` | Public IP (if Elastic IP enabled) |
| `private_dns` | Private DNS name |
| `public_dns` | Public DNS name (if reachable) |
| `availability_zone` | AZ where the instance runs |
| `instance_state` | Current instance state |
| `security_group_id` | Managed security group ID |
| `elastic_ip` | Elastic IP address (if created) |
| `resolved_tags` | Final tag map applied to the instance |
| `resolved_instance_type` | Effective instance type after defaults |
| `resolved_root_volume_size` | Effective root volume size (GB) |
| `ssh_user` | SSH username for the VM (based on OS) |
| `ssh_command` | Ready-to-use SSH command |
| `docker_installed` | Whether Docker was installed |
| `jenkins_installed` | Whether Jenkins was installed |
| `jenkins_url` | Jenkins web interface URL |
| `jenkins_admin_password` | Jenkins admin password (sensitive) |

## Security & Cost Notes

- Restrict `allowed_cidrs` to your corporate IP ranges whenever possible.
- Use AWS Systems Manager Session Manager for passwordless shell access.
- Leave `enable_auto_shutdown = true` for sandbox/training work to avoid surprise costs.
- Detailed monitoring adds ~10% cost on small instances; keep it disabled unless needed.

## Troubleshooting

- **No public IP?** Ensure `enable_eip = true` (default) or supply a subnet with `map_public_ip_on_launch = true`.
- **AMI errors?** Disable `use_latest_ami` and supply a known-good `ami_id` in regions without Amazon Linux 2023.
- **Permissions denied?** Confirm your IAM role allows `ec2:Describe*`, `ec2:RunInstances`, `ec2:AssociateAddress`, and tagging actions.

## References

- [Amazon EC2 Pricing](https://aws.amazon.com/ec2/pricing/)
- [Amazon Linux 2023](https://aws.amazon.com/linux/amazon-linux-2023/)
- [Managing Default VPCs](https://docs.aws.amazon.com/vpc/latest/userguide/default-vpc.html)
- [Instance Scheduler Alternatives](https://aws.amazon.com/instance-scheduler/)

---

**Cost posture**: ⚠️ Pay-as-you-go (free-tier friendly in `dev`)  
**Auto-expiry**: ✅ Shuts down after 4 hours by default  
**Managed by**: terraform
