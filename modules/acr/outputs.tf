# modules/acr/outputs.tf
output "acr_id" {
  description = "ID of the Azure Container Registry"
  value       = azurerm_container_registry.acr.id
}

output "login_server" {
  description = "Login server for the Azure Container Registry"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_name" {
  description = "Name of the Azure Container Registry"
  value       = azurerm_container_registry.acr.name
}

output "admin_username" {
  description = "Admin username for the Azure Container Registry"
  value       = azurerm_container_registry.acr.admin_username
}

output "admin_password" {
  description = "Admin password for the Azure Container Registry"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}
