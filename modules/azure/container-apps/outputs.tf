output "id" {
  description = "Container App ID"
  value       = azurerm_container_app.this.id
}

output "name" {
  description = "Container App name"
  value       = azurerm_container_app.this.name
}

output "fqdn" {
  description = "Fully qualified domain name (if ingress enabled)"
  value       = var.enable_ingress ? azurerm_container_app.this.ingress[0].fqdn : null
}

output "environment_id" {
  description = "Container App Environment ID"
  value       = azurerm_container_app_environment.this.id
}

