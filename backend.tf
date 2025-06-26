##############################
# Root Files
##############################

# backend.tf
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-aks-demo"
    storage_account_name = "tfstateaksdemo"
    container_name       = "tfstate"
    key                  = "aks.terraform.tfstate"
  }
}








