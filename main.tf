# main.tf
module "log_analytics" {
  source                       = "./modules/log-analytics"
  resource_group               = var.resource_group
  location                     = var.location
  log_analytics_workspace_name = var.log_analytics_workspace_name
  log_retention_days           = var.log_retention_days
}

module "network" {
  source         = "./modules/network"
  resource_group = var.resource_group
  location       = var.location
  vnet_name      = var.vnet_name
  vnet_cidr      = var.vnet_cidr
}

module "acr" {
  source         = "./modules/acr"
  resource_group = var.resource_group
  location       = var.location
  acr_name       = var.acr_name
}

module "keyvault" {
  source         = "./modules/keyvault"
  resource_group = var.resource_group
  location       = var.location
  kv_name        = var.kv_name
}

module "aks" {
  source                     = "./modules/aks"
  resource_group             = var.resource_group
  location                   = var.location
  aks_name                   = var.aks_name
  dns_prefix                 = var.dns_prefix
  vnet_subnet_id             = module.network.subnet_id
  acr_id                     = module.acr.acr_id
  aad_group_object_id        = var.aad_group_object_id
  tenant_id                  = var.tenant_id
  log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
}

module "monitoring" {
  source                    = "./modules/monitoring"
  resource_group            = var.resource_group
  location                  = var.location
  log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
  application_insights_name = var.application_insights_name
  aks_cluster_id            = module.aks.cluster_id
  aks_cluster_name          = module.aks.cluster_name
  acr_id                    = module.acr.acr_id
  key_vault_id              = module.keyvault.key_vault_id
  alert_email               = var.alert_email
}
