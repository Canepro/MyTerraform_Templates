output "id" {
  description = "The ID of the virtual machine"
  value       = azurerm_linux_virtual_machine.this.id
}

output "name" {
  description = "The name of the virtual machine"
  value       = azurerm_linux_virtual_machine.this.name
}

output "private_ip_address" {
  description = "The private IP address of the VM"
  value       = azurerm_network_interface.this.private_ip_address
}

output "public_ip_address" {
  description = "The public IP address of the VM (if enabled)"
  value       = var.enable_public_ip ? azurerm_public_ip.this[0].ip_address : null
}

output "admin_username" {
  description = "The admin username for SSH access"
  value       = azurerm_linux_virtual_machine.this.admin_username
}

output "network_interface_id" {
  description = "The ID of the network interface"
  value       = azurerm_network_interface.this.id
}

output "identity_principal_id" {
  description = "The principal ID of the system-assigned managed identity (if enabled)"
  value       = var.enable_managed_identity ? azurerm_linux_virtual_machine.this.identity[0].principal_id : null
}

output "network_security_group_id" {
  description = "The ID of the managed network security group"
  value       = azurerm_network_security_group.this.id
}

output "resolved_tags" {
  description = "All tags applied to the VM and related resources"
  value       = merge(
    local.baseline_tags,
    {
      Name = var.name
    }
  )
}

output "resolved_vm_size" {
  description = "VM size after applying environment defaults"
  value       = local.resolved_vm_size
}

output "resolved_os_disk_size_gb" {
  description = "OS disk size after applying environment defaults"
  value       = local.resolved_os_disk_size_gb
}

output "docker_installed" {
  description = "Whether Docker is installed on this VM"
  value       = var.install_docker
}

output "jenkins_installed" {
  description = "Whether Jenkins is installed on this VM"
  value       = var.install_jenkins
}

output "jenkins_url" {
  description = "Jenkins web interface URL (if Jenkins is installed)"
  value       = var.install_jenkins && var.enable_public_ip ? format("http://%s:8080", azurerm_public_ip.this[0].ip_address) : null
}

output "jenkins_admin_password" {
  description = "Jenkins initial admin password location: /var/lib/jenkins/secrets/initialAdminPassword (SSH to VM to retrieve)"
  value       = var.install_jenkins ? "SSH to VM and run: sudo cat /var/lib/jenkins/secrets/initialAdminPassword" : null
}

