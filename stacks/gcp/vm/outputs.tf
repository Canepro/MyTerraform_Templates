output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = google_compute_instance.this.network_interface[0].access_config[0].nat_ip
}

output "vm_private_ip" {
  description = "Private IP address of the VM"
  value       = google_compute_instance.this.network_interface[0].network_ip
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh ${var.ssh_user}@${google_compute_instance.this.network_interface[0].access_config[0].nat_ip}"
}

output "instance_name" {
  description = "GCP instance name"
  value       = google_compute_instance.this.name
}

output "instance_zone" {
  description = "Instance zone"
  value       = google_compute_instance.this.zone
}

output "destroy_command" {
  description = "Command to destroy all resources"
  value       = "terraform destroy"
}
