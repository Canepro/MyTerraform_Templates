output "user_name" {
  description = "User name"
  value       = aws_iam_user.this.name
}

output "user_arn" {
  description = "User ARN"
  value       = aws_iam_user.this.arn
}

output "access_key_id" {
  description = "Access key ID"
  value       = var.create_access_key ? aws_iam_access_key.this[0].id : null
  sensitive   = true
}

output "secret_access_key" {
  description = "Secret access key"
  value       = var.create_access_key ? aws_iam_access_key.this[0].secret : null
  sensitive   = true
}

