output "id" {
  description = "App Service ID"
  value       = azurerm_linux_web_app.this.id
}

output "name" {
  description = "App Service name"
  value       = azurerm_linux_web_app.this.name
}

output "default_hostname" {
  description = "Default hostname"
  value       = azurerm_linux_web_app.this.default_hostname
}

output "outbound_ip_addresses" {
  description = "Outbound IP addresses"
  value       = azurerm_linux_web_app.this.outbound_ip_addresses
}

output "service_plan_id" {
  description = "Service Plan ID"
  value       = azurerm_service_plan.this.id
}

