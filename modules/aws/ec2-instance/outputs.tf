output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.this.id
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.this.arn
}

output "private_ip" {
  description = "Private IP address of the instance"
  value       = aws_instance.this.private_ip
}

output "public_ip" {
  description = "Public IP address of the instance (Elastic IP if enabled, otherwise instance public IP)"
  value       = var.enable_eip ? aws_eip.this[0].public_ip : aws_instance.this.public_ip
}

output "private_dns" {
  description = "Private DNS name of the instance"
  value       = aws_instance.this.private_dns
}

output "public_dns" {
  description = "Public DNS name of the instance (Elastic IP DNS if enabled, otherwise instance public DNS)"
  value       = var.enable_eip ? aws_eip.this[0].public_dns : aws_instance.this.public_dns
}

output "availability_zone" {
  description = "Availability zone where the instance is running"
  value       = aws_instance.this.availability_zone
}

output "instance_state" {
  description = "State of the instance"
  value       = aws_instance.this.instance_state
}

output "security_group_id" {
  description = "ID of the managed security group"
  value       = aws_security_group.this.id
}

output "elastic_ip" {
  description = "Elastic IP address attached to the instance (if enabled)"
  value       = var.enable_eip ? aws_eip.this[0].public_ip : null
}

output "resolved_tags" {
  description = "All tags applied to the instance"
  value       = local.name_tag
}

output "resolved_instance_type" {
  description = "Instance type after applying environment defaults"
  value       = local.resolved_instance_type
}

output "resolved_root_volume_size" {
  description = "Root volume size after applying environment defaults"
  value       = local.resolved_root_volume_size
}

output "ssh_user" {
  description = "SSH username based on OS distribution"
  value       = var.os_distribution == "amazon-linux" ? "ec2-user" : "ubuntu"
}

output "ssh_command" {
  description = "Ready-to-use SSH command to connect to the instance"
  value = format(
    "ssh -i ~/.ssh/%s.pem %s@%s",
    var.key_name,
    var.os_distribution == "amazon-linux" ? "ec2-user" : "ubuntu",
    var.enable_eip ? aws_eip.this[0].public_ip : aws_instance.this.public_ip
  )
}

output "docker_installed" {
  description = "Whether Docker is installed on this instance"
  value       = var.install_docker
}

output "jenkins_installed" {
  description = "Whether Jenkins is installed on this instance"
  value       = var.install_jenkins
}

output "jenkins_url" {
  description = "Jenkins web interface URL (if Jenkins is installed)"
  value       = var.install_jenkins ? format("http://%s:8080", var.enable_eip ? aws_eip.this[0].public_ip : aws_instance.this.public_ip) : null
}

output "jenkins_admin_password" {
  description = "Jenkins initial admin password location: /var/lib/jenkins/secrets/initialAdminPassword (SSH to VM to retrieve)"
  value       = var.install_jenkins ? "SSH to VM and run: sudo cat /var/lib/jenkins/secrets/initialAdminPassword" : null
}
