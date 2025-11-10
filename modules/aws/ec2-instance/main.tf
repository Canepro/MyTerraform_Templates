terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  environment_profiles = {
    dev = {
      instance_type    = "t3.micro"
      root_volume_size = 30
    }
    training = {
      instance_type    = "t3.medium"
      root_volume_size = 50
    }
    prod = {
      instance_type    = "t3.large"
      root_volume_size = 100
    }
  }

  ami_configs = {
    "amazon-linux" = {
      owners  = ["amazon"]
      name    = "al2023-ami-*-x86_64"
      filters = []
    }
    ubuntu = {
      owners = ["099720109477"]
      name   = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      filters = [
        {
          name   = "virtualization-type"
          values = ["hvm"]
        },
        {
          name   = "root-device-type"
          values = ["ebs"]
        }
      ]
    }
  }

  # Docker installation scripts - defined as standalone strings
  docker_amazon_linux_script = <<-EODOCKER
#!/bin/bash
# Install Docker on Amazon Linux
dnf update -y
dnf install -y docker
systemctl enable docker
systemctl start docker
usermod -a -G docker ec2-user
EODOCKER

  docker_ubuntu_script = <<-EOUBUNTU
#!/bin/bash
# Install Docker on Ubuntu
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable docker
systemctl start docker
usermod -a -G docker ubuntu
EOUBUNTU

  # Jenkins installation scripts - native installation (not Docker)
  jenkins_amazon_linux_script = <<-EOJENKINS
#!/bin/bash
# Install Jenkins on Amazon Linux (LTS version)
# Install Java 21
dnf install -y fontconfig java-21-openjdk

# Add Jenkins repository and install
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
dnf upgrade -y
dnf install -y jenkins
systemctl daemon-reload

# Enable and start Jenkins
systemctl enable jenkins
systemctl start jenkins

# Wait for Jenkins to generate initial admin password
sleep 30
EOJENKINS

  jenkins_ubuntu_script = <<-EOJENKINS
#!/bin/bash
# Install Jenkins on Ubuntu (LTS version)
# Install Java 21
apt-get update -y
apt-get install -y fontconfig openjdk-21-jre

# Add Jenkins repository and install
wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list > /dev/null
apt-get update -y
apt-get install -y jenkins

# Enable and start Jenkins
systemctl enable jenkins
systemctl start jenkins

# Wait for Jenkins to generate initial admin password
sleep 30
EOJENKINS

  # Select appropriate scripts based on OS
  selected_docker_script = var.install_docker ? (var.os_distribution == "amazon-linux" ? local.docker_amazon_linux_script : local.docker_ubuntu_script) : ""
  selected_jenkins_script = var.install_jenkins ? (var.os_distribution == "amazon-linux" ? local.jenkins_amazon_linux_script : local.jenkins_ubuntu_script) : ""

  # Combine scripts
  software_install_script = join("\n\n", compact([local.selected_docker_script, local.selected_jenkins_script]))
}

data "aws_vpc" "default" {
  count   = var.vpc_id == null ? 1 : 0
  default = true
}

data "aws_vpc" "selected" {
  count = var.vpc_id != null ? 1 : 0
  id    = var.vpc_id
}

data "aws_subnets" "default_all" {
  count = var.subnet_id == null && var.availability_zone == null ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [var.vpc_id != null ? var.vpc_id : data.aws_vpc.default[0].id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

data "aws_subnets" "default_in_az" {
  count = var.subnet_id == null && var.availability_zone != null ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [var.vpc_id != null ? var.vpc_id : data.aws_vpc.default[0].id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }

  filter {
    name   = "availability-zone"
    values = [var.availability_zone]
  }
}

data "aws_ami" "selected" {
  count = var.use_latest_ami ? 1 : 0

  most_recent = true
  owners      = local.ami_configs[var.os_distribution].owners

  filter {
    name   = "name"
    values = [local.ami_configs[var.os_distribution].name]
  }

  filter {
    name   = "state"
    values = ["available"]
  }

  dynamic "filter" {
    for_each = local.ami_configs[var.os_distribution].filters
    content {
      name   = filter.value.name
      values = filter.value.values
    }
  }
}

locals {
  resolved_vpc_id = var.vpc_id != null ? var.vpc_id : data.aws_vpc.default[0].id

  resolved_subnet_id = var.subnet_id != null ? var.subnet_id : (
    var.availability_zone != null ?
    element(data.aws_subnets.default_in_az[0].ids, 0) :
    element(data.aws_subnets.default_all[0].ids, 0)
  )

  resolved_instance_type = coalesce(
    var.instance_type,
    local.environment_profiles[var.environment].instance_type
  )

  resolved_root_volume_size = coalesce(
    var.root_volume_size,
    local.environment_profiles[var.environment].root_volume_size
  )

  ami_id = var.use_latest_ami ? data.aws_ami.selected[0].id : var.ami_id

  baseline_tags = merge(
    {
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "terraform"
    },
    var.tags
  )

  name_tag = merge(
    local.baseline_tags,
    {
      Name = var.name
    }
  )

  user_data_template = <<-EOT
#!/bin/bash
set -euxo pipefail

${local.software_install_script}
( sleep ${var.auto_shutdown_hours * 3600} && shutdown -h now ) &
EOT

  rendered_user_data = var.enable_auto_shutdown ? (
    var.user_data != null && trimspace(var.user_data) != "" ?
    "${local.user_data_template}\n\n# Additional user data\n${trimspace(var.user_data)}" :
    local.user_data_template
  ) : (
    var.user_data != null && trimspace(var.user_data) != "" ?
    "${local.software_install_script}\n\n# Additional user data\n${trimspace(var.user_data)}" :
    local.software_install_script != "" ? local.software_install_script : var.user_data
  )
}

resource "aws_security_group" "this" {
  name_prefix = "${var.name}-"
  description = "Managed security group for ${var.name}"
  vpc_id      = local.resolved_vpc_id

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      description = "Allow TCP ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.allowed_cidrs
    }
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.baseline_tags,
    {
      Name = "${var.name}-sg"
    }
  )
}

resource "aws_instance" "this" {
  ami                    = local.ami_id
  instance_type          = local.resolved_instance_type
  subnet_id              = local.resolved_subnet_id
  vpc_security_group_ids = concat([aws_security_group.this.id], var.additional_security_group_ids)
  key_name               = var.key_name

  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = local.resolved_root_volume_size
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring = var.enable_detailed_monitoring

  user_data = local.rendered_user_data

  iam_instance_profile = var.iam_instance_profile

  disable_api_termination = var.enable_termination_protection

  tags = local.name_tag

  volume_tags = local.baseline_tags

  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_eip" "this" {
  count  = var.enable_eip ? 1 : 0
  domain = "vpc"

  instance = aws_instance.this.id

  tags = merge(
    local.baseline_tags,
    {
      Name = "${var.name}-eip"
    }
  )
}
