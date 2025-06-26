# modules/aks/main.tf
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group
  dns_prefix          = var.dns_prefix

  # Security: Disable local admin account (requires Azure AD integration)
  # local_account_disabled = true

  default_node_pool {
    name                 = "default"
    vm_size              = "Standard_DS2_v2"
    node_count           = 1
    auto_scaling_enabled = true
    min_count            = 1
    max_count            = 3
    vnet_subnet_id       = var.vnet_subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.aad_group_object_id != "" ? [1] : []
    content {
      azure_rbac_enabled     = true
      admin_group_object_ids = [var.aad_group_object_id]
      tenant_id              = var.tenant_id
    }
  }

  network_profile {
    network_plugin = "azure"
    dns_service_ip = "10.2.0.10"
    service_cidr   = "10.2.0.0/16"
  }
}

# Grant AKS access to ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}