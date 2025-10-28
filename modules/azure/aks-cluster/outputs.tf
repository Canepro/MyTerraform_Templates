output "id" {
  description = "The ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.id
}

output "name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.name
}

output "fqdn" {
  description = "The FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.fqdn
}

output "kube_config" {
  description = "Kubernetes configuration file"
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "node_resource_group" {
  description = "The auto-generated resource group for AKS nodes"
  value       = azurerm_kubernetes_cluster.this.node_resource_group
}

output "identity_principal_id" {
  description = "The principal ID of the system-assigned managed identity"
  value       = azurerm_kubernetes_cluster.this.identity[0].principal_id
}

