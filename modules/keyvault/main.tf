# modules/keyvault/main.tf
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                       = var.kv_name
  location                   = var.location
  resource_group_name        = var.resource_group
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = false # Changed to false for easier cleanup in demo
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get",
      "List",
      "Create",
      "Delete",
      "Update",
      "Purge",
      "Recover"
    ]

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Purge",
      "Recover"
    ]
  }
}
