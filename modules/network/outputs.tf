# modules/network/outputs.tf
output "subnet_id" {
  description = "ID of the AKS subnet"
  value       = azurerm_subnet.subnet.id
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}
