output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = module.azure_vm.public_ip_address
}

output "vm_private_ip" {
  description = "Private IP address of the VM"
  value       = module.azure_vm.private_ip_address
}

output "vm_id" {
  description = "VM resource ID"
  value       = module.azure_vm.id
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh ${module.azure_vm.admin_username}@${module.azure_vm.public_ip_address}"
}

output "resource_group_name" {
  description = "Resource group name"
  value       = local.resource_group_name
}

output "network_security_group_id" {
  description = "Network security group ID"
  value       = module.azure_vm.network_security_group_id
}

output "resolved_vm_size" {
  description = "Actual VM size used (after environment defaults)"
  value       = module.azure_vm.resolved_vm_size
}

output "resolved_os_disk_size_gb" {
  description = "Actual OS disk size (after environment defaults)"
  value       = module.azure_vm.resolved_os_disk_size_gb
}

output "docker_installed" {
  description = "Whether Docker is installed"
  value       = module.azure_vm.docker_installed
}

output "jenkins_installed" {
  description = "Whether Jenkins is installed"
  value       = module.azure_vm.jenkins_installed
}

output "jenkins_url" {
  description = "Jenkins web interface URL"
  value       = module.azure_vm.jenkins_url
}

output "jenkins_admin_password" {
  description = "Jenkins admin password (use 'terraform output jenkins_admin_password' to view)"
  value       = module.azure_vm.jenkins_admin_password
  sensitive   = true
}

output "destroy_command" {
  description = "Command to destroy all resources"
  value       = "terraform destroy"
}
