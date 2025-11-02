terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Random suffix for globally unique bucket names
resource "random_id" "suffix" {
  byte_length = 4
}

# Common naming convention
module "naming" {
  source = "../../../modules/common/naming"

  prefix      = var.prefix
  environment = var.environment
  suffix      = var.suffix
}

# Common tags
module "tags" {
  source = "../../../modules/common/tags"

  environment = var.environment
  managed_by  = "terraform"
  cost_center = var.cost_center
  custom_tags = var.custom_tags
}

# VPC Network with Subnets
module "vpc" {
  source = "../../../modules/gcp/vpc"

  name = module.naming.virtual_network

  subnets = var.subnets
}

# Cloud Storage Bucket
module "storage_bucket" {
  source = "../../../modules/gcp/storage-bucket"

  bucket_name       = "${var.prefix}-${var.environment}-${random_id.suffix.hex}"
  location          = var.region
  enable_versioning = false  # Disable for sandbox to save costs
  force_destroy     = true   # Allow easy cleanup

  labels = module.tags.tags
}

# Firewall rule for SSH (optional, for future VM deployments)
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.prefix}-${var.environment}-allow-ssh"
  network = module.vpc.network_name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  # Allow SSH from anywhere (customize in production!)
  source_ranges = ["0.0.0.0/0"]

  target_tags = ["ssh-enabled"]

  description = "Allow SSH access for sandbox"
}

