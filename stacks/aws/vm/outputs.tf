output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = module.ec2_vm.public_ip
}

output "vm_private_ip" {
  description = "Private IP address of the VM"
  value       = module.ec2_vm.private_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2_vm.instance_id
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = module.ec2_vm.ssh_command
}

output "ssh_user" {
  description = "SSH username for the VM"
  value       = module.ec2_vm.ssh_user
}

output "elastic_ip" {
  description = "Elastic IP address (if enabled)"
  value       = module.ec2_vm.elastic_ip
}

output "public_dns" {
  description = "Public DNS name"
  value       = module.ec2_vm.public_dns
}

output "security_group_id" {
  description = "Security group ID"
  value       = module.ec2_vm.security_group_id
}

output "resolved_instance_type" {
  description = "Actual instance type used (after environment defaults)"
  value       = module.ec2_vm.resolved_instance_type
}

output "resolved_root_volume_size" {
  description = "Actual root volume size (after environment defaults)"
  value       = module.ec2_vm.resolved_root_volume_size
}

output "docker_installed" {
  description = "Whether Docker is installed"
  value       = module.ec2_vm.docker_installed
}

output "jenkins_installed" {
  description = "Whether Jenkins is installed"
  value       = module.ec2_vm.jenkins_installed
}

output "jenkins_url" {
  description = "Jenkins web interface URL"
  value       = module.ec2_vm.jenkins_url
}

output "jenkins_admin_password" {
  description = "Jenkins admin password (use 'terraform output jenkins_admin_password' to view)"
  value       = module.ec2_vm.jenkins_admin_password
  sensitive   = true
}

output "destroy_command" {
  description = "Command to destroy all resources"
  value       = "terraform destroy"
}
