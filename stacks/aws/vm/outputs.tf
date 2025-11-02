output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = var.enable_eip && length(aws_eip.this) > 0 ? aws_eip.this[0].public_ip : aws_instance.this.public_ip
}

output "vm_private_ip" {
  description = "Private IP address of the VM"
  value       = aws_instance.this.private_ip
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = var.key_path != "" ? "ssh ec2-user@${var.enable_eip && length(aws_eip.this) > 0 ? aws_eip.this[0].public_ip : aws_instance.this.public_ip} -i ${var.key_path}" : "ssh ec2-user@${var.enable_eip && length(aws_eip.this) > 0 ? aws_eip.this[0].public_ip : aws_instance.this.public_ip}"
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.this.id
}

output "ami_id" {
  description = "AMI ID used for the instance"
  value       = data.aws_ami.amazon_linux_2023.id
}

output "destroy_command" {
  description = "Command to destroy all resources"
  value       = "terraform destroy"
}
