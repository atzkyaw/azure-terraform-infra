# main.tf
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
  source              = "./modules/aks"
  resource_group      = var.resource_group
  location            = var.location
  aks_name            = var.aks_name
  dns_prefix          = var.dns_prefix
  vnet_subnet_id      = module.network.subnet_id
  acr_id              = module.acr.acr_id
  aad_group_object_id = var.aad_group_object_id
  tenant_id           = var.tenant_id
}
