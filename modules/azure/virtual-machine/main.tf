terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

locals {
  environment_profiles = {
    dev = {
      vm_size        = "Standard_B1s"
      os_disk_size_gb = 30
    }
    training = {
      vm_size        = "Standard_B2ms"
      os_disk_size_gb = 50
    }
    prod = {
      vm_size        = "Standard_D2s_v3"
      os_disk_size_gb = 100
    }
  }

  image_configs = {
    ubuntu = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts-gen2"
      version   = "latest"
    }
    azure-linux = {
      publisher = "MicrosoftCBLMariner"
      offer     = "cbl-mariner"
      sku       = "cbl-mariner-2"
      version   = "latest"
    }
  }

  baseline_tags = merge(
    {
      Environment = var.environment
      Project     = var.project
      ManagedBy   = "terraform"
    },
    var.tags
  )

  resolved_vm_size = coalesce(
    var.vm_size,
    local.environment_profiles[var.environment].vm_size
  )

  resolved_os_disk_size_gb = coalesce(
    var.os_disk_size_gb,
    local.environment_profiles[var.environment].os_disk_size_gb
  )

  auto_shutdown_time = var.enable_auto_shutdown ? formatdate(
    "HHmm",
    timeadd(timestamp(), "${var.auto_shutdown_hours}h")
  ) : null

  # Docker installation scripts
  docker_install_ubuntu = <<-DOCKER
# Install Docker
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
usermod -a -G docker ${var.admin_username}
DOCKER

  docker_install_azure_linux = <<-DOCKER
# Install Docker
dnf update -y
dnf install -y moby-engine moby-cli
systemctl enable docker
systemctl start docker
usermod -a -G docker ${var.admin_username}
DOCKER

  # Jenkins installation scripts - native installation (not Docker)
  jenkins_ubuntu_script = <<-JENKINS
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
JENKINS

  jenkins_azure_linux_script = <<-JENKINS
#!/bin/bash
# Install Jenkins on Azure Linux (LTS version)
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
JENKINS

  # Combined installation script based on OS
  docker_script  = var.install_docker ? (var.os_distribution == "ubuntu" ? local.docker_install_ubuntu : local.docker_install_azure_linux) : ""
  jenkins_script = var.install_jenkins ? (var.os_distribution == "ubuntu" ? local.jenkins_ubuntu_script : local.jenkins_azure_linux_script) : ""

  custom_data = var.install_docker || var.install_jenkins ? base64encode(<<-CUSTOMDATA
#!/bin/bash
set -euxo pipefail

${local.docker_script}
${local.jenkins_script}

CUSTOMDATA
  ) : null
}

resource "azurerm_public_ip" "this" {
  count = var.enable_public_ip ? 1 : 0

  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = local.baseline_tags
}

resource "azurerm_network_security_group" "this" {
  name                = "${var.name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-managed-ports"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefixes    = var.allowed_cidrs
    destination_port_ranges    = [for port in var.allowed_ports : tostring(port)]
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-egress"
    priority                   = 2000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.baseline_tags
}

resource "azurerm_network_interface" "this" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.enable_public_ip ? azurerm_public_ip.this[0].id : null
  }

  tags = local.baseline_tags
}

resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}

resource "azurerm_linux_virtual_machine" "this" {
  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  size                            = local.resolved_vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.this.id]
  custom_data                     = local.custom_data

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_storage_account_type
    disk_size_gb         = local.resolved_os_disk_size_gb
  }

  source_image_reference {
    publisher = local.image_configs[var.os_distribution].publisher
    offer     = local.image_configs[var.os_distribution].offer
    sku       = local.image_configs[var.os_distribution].sku
    version   = local.image_configs[var.os_distribution].version
  }

  dynamic "identity" {
    for_each = var.enable_managed_identity ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }

  tags = merge(
    local.baseline_tags,
    {
      Name = var.name
    }
  )
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "this" {
  count = var.enable_auto_shutdown ? 1 : 0

  virtual_machine_id = azurerm_linux_virtual_machine.this.id
  location           = var.location
  enabled            = true

  daily_recurrence_time = local.auto_shutdown_time
  timezone              = var.auto_shutdown_timezone

  notification_settings {
    enabled = var.auto_shutdown_notification_enabled
  }

  tags = local.baseline_tags
}

