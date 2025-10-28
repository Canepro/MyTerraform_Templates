output "network_id" {
  description = "Network ID"
  value       = google_compute_network.this.id
}

output "network_name" {
  description = "Network name"
  value       = google_compute_network.this.name
}

output "subnet_ids" {
  description = "Subnet IDs"
  value       = google_compute_subnetwork.this[*].id
}

