# modules/aks/variables.tf
variable "resource_group" {}
variable "location" {}
variable "aks_name" {}
variable "dns_prefix" {}
variable "vnet_subnet_id" {}
variable "acr_id" {}
variable "aad_group_object_id" {}
variable "tenant_id" {}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace for Container Insights"
  type        = string
  default     = ""
}
