# VPC Outputs
output "network_id" {
  description = "ID of the VPC network"
  value       = module.vpc.network_id
}

output "network_name" {
  description = "Name of the VPC network"
  value       = module.vpc.network_name
}

output "subnet_ids" {
  description = "IDs of the subnets"
  value       = module.vpc.subnet_ids
}

# Storage Outputs
output "bucket_name" {
  description = "Name of the Cloud Storage bucket"
  value       = module.storage_bucket.name
}

output "bucket_url" {
  description = "URL of the Cloud Storage bucket"
  value       = module.storage_bucket.url
}

# Firewall Outputs
output "ssh_firewall_name" {
  description = "Name of the SSH firewall rule"
  value       = google_compute_firewall.allow_ssh.name
}

