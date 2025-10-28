output "resource_group" {
  description = "Generated name for resource group"
  value       = local.resource_group
}

output "storage_account" {
  description = "Generated name for storage account (lowercase, no hyphens, max 24 chars)"
  value       = substr(local.storage_account, 0, min(24, length(local.storage_account)))
}

output "virtual_network" {
  description = "Generated name for virtual network"
  value       = local.virtual_network
}

output "subnet" {
  description = "Generated name for subnet"
  value       = local.subnet
}

output "network_security_group" {
  description = "Generated name for network security group"
  value       = local.network_security_group
}

output "public_ip" {
  description = "Generated name for public IP address"
  value       = local.public_ip
}

output "load_balancer" {
  description = "Generated name for load balancer"
  value       = local.load_balancer
}

output "virtual_machine" {
  description = "Generated name for virtual machine"
  value       = local.virtual_machine
}

output "key_vault" {
  description = "Generated name for Key Vault (lowercase, max 24 chars)"
  value       = substr(local.key_vault, 0, min(24, length(local.key_vault)))
}

output "app_service" {
  description = "Generated name for App Service"
  value       = local.app_service
}

output "function_app" {
  description = "Generated name for Function App"
  value       = local.function_app
}

output "sql_server" {
  description = "Generated name for SQL Server"
  value       = local.sql_server
}

output "cosmos_db" {
  description = "Generated name for Cosmos DB"
  value       = local.cosmos_db
}

output "aks_cluster" {
  description = "Generated name for AKS cluster"
  value       = local.aks_cluster
}

output "container_registry" {
  description = "Generated name for Container Registry (alphanumeric only, max 50 chars)"
  value       = substr(local.container_registry, 0, min(50, length(local.container_registry)))
}

output "app_insights" {
  description = "Generated name for Application Insights"
  value       = local.app_insights
}

output "log_analytics_workspace" {
  description = "Generated name for Log Analytics Workspace"
  value       = local.log_analytics_workspace
}

