output "resource_group_name" {
  description = "Name of the created resource group"
  value       = module.resource_group.name
}

output "resource_group_id" {
  description = "ID of the created resource group"
  value       = module.resource_group.id
}

output "storage_account_name" {
  description = "Name of the created storage account"
  value       = module.storage_account.name
}

output "storage_account_primary_blob_endpoint" {
  description = "Primary blob endpoint for the storage account"
  value       = module.storage_account.primary_blob_endpoint
}

output "virtual_network_name" {
  description = "Name of the created virtual network"
  value       = module.virtual_network.name
}

output "virtual_network_id" {
  description = "ID of the created virtual network"
  value       = module.virtual_network.id
}

output "subnet_ids" {
  description = "Map of subnet names to their IDs"
  value       = module.virtual_network.subnet_ids
}

output "tags" {
  description = "Common tags applied to all resources"
  value       = module.tags.tags
}

