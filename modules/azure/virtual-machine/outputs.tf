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

