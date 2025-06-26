# modules/log-analytics/variables.tf

variable "resource_group" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain logs in Log Analytics"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to Log Analytics resources"
  type        = map(string)
  default = {
    Environment = "demo"
    Project     = "aks-monitoring"
    ManagedBy   = "terraform"
  }
}
