output "email" {
  description = "Service account email"
  value       = google_service_account.this.email
}

output "name" {
  description = "Service account name"
  value       = google_service_account.this.name
}

output "private_key" {
  description = "Private key (if created)"
  value       = var.create_key ? google_service_account_key.this[0].private_key : null
  sensitive   = true
}

