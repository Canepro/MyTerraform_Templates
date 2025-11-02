output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.this.ip_address
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.this.ip_address}"
}

output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.this.name
}

output "vm_name" {
  description = "VM name"
  value       = azurerm_linux_virtual_machine.this.name
}

output "destroy_command" {
  description = "Command to destroy all resources"
  value       = "terraform destroy"
}
