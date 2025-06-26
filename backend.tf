##############################
# Root Files
##############################

# backend.tf
# Note: These values are environment-specific and should be updated for different deployments
# Consider using partial configuration or environment variables for production
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-aks-demo"
    storage_account_name = "tfstateaksdemo"
    container_name       = "tfstate"
    key                  = "aks.terraform.tfstate"
  }
}








