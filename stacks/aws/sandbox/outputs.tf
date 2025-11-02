# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

# S3 Outputs
output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.s3_bucket.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3_bucket.bucket_arn
}

# Security Group Outputs
output "security_group_id" {
  description = "ID of the default security group"
  value       = aws_security_group.default.id
}

output "ssh_command_example" {
  description = "Example SSH command (when EC2 instance is created)"
  value       = "Use this security group ID to SSH into EC2 instances: ${aws_security_group.default.id}"
}

