terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# VPC Network
resource "google_compute_network" "this" {
  name                    = "${var.project_name}-vpc"
  auto_create_subnetworks = false

  delete_default_routes_on_create = false
}

# Subnet
resource "google_compute_subnetwork" "this" {
  name          = "${var.project_name}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.this.id
}

# Firewall Rule - Allow SSH
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.project_name}-allow-ssh"
  network = google_compute_network.this.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-enabled"]
}

# Firewall Rule - Allow ICMP (for ping)
resource "google_compute_firewall" "allow_icmp" {
  name    = "${var.project_name}-allow-icmp"
  network = google_compute_network.this.name

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

# Get Latest Ubuntu 22.04 Image
data "google_compute_image" "ubuntu" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}

# Compute Instance
resource "google_compute_instance" "this" {
  name         = "${var.project_name}-vm"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
      size  = var.boot_disk_size
      type  = var.boot_disk_type
    }
  }

  network_interface {
    network    = google_compute_network.this.name
    subnetwork = google_compute_subnetwork.this.name

    access_config {
      # Ephemeral public IP
    }
  }

  # SSH Key from metadata
  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }

  # Tag for firewall rules
  tags = ["ssh-enabled"]

  labels = {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
  }

  metadata_startup_script = var.startup_script
}
