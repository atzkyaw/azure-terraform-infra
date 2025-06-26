# variables.tf
variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "southeastasia"
}

variable "resource_group" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-aks-demo"
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
  default     = "aks-vnet"
}

variable "vnet_cidr" {
  description = "CIDR block for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aks_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "demoaks"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "demoaks"
}

variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
  default     = "demoacr1234"
}

variable "kv_name" {
  description = "Name of the Key Vault"
  type        = string
  default     = "demokv1234"
}

variable "aad_group_object_id" {
  description = "Object ID of the Azure AD group for AKS admin access"
  type        = string
  default     = ""
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
  default     = ""
}