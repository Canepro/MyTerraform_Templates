terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

resource "azurerm_storage_account" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind
  access_tier              = var.access_tier

  # Security settings
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = var.allow_public_access
  public_network_access_enabled   = var.public_network_access_enabled

  # Optional: Blob properties
  dynamic "blob_properties" {
    for_each = var.enable_blob_versioning || var.enable_change_feed ? [1] : []
    content {
      versioning_enabled  = var.enable_blob_versioning
      change_feed_enabled = var.enable_change_feed

      dynamic "delete_retention_policy" {
        for_each = var.blob_soft_delete_retention_days > 0 ? [1] : []
        content {
          days = var.blob_soft_delete_retention_days
        }
      }

      dynamic "container_delete_retention_policy" {
        for_each = var.container_soft_delete_retention_days > 0 ? [1] : []
        content {
          days = var.container_soft_delete_retention_days
        }
      }
    }
  }

  tags = var.tags
}

