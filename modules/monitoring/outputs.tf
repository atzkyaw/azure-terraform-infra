# modules/monitoring/outputs.tf

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = var.log_analytics_workspace_id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = data.azurerm_log_analytics_workspace.main.name
}

output "log_analytics_workspace_key" {
  description = "Primary key of the Log Analytics workspace"
  value       = data.azurerm_log_analytics_workspace.main.primary_shared_key
  sensitive   = true
}

output "application_insights_id" {
  description = "ID of the Application Insights instance"
  value       = azurerm_application_insights.main.id
}

output "application_insights_name" {
  description = "Name of the Application Insights instance"
  value       = azurerm_application_insights.main.name
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  value       = azurerm_application_insights.main.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Connection string for Application Insights"
  value       = azurerm_application_insights.main.connection_string
  sensitive   = true
}

output "action_group_id" {
  description = "ID of the monitoring action group"
  value       = azurerm_monitor_action_group.main.id
}

output "monitoring_dashboard_url" {
  description = "URL to access the monitoring dashboard"
  value       = "https://portal.azure.com/#@${split("/", var.log_analytics_workspace_id)[2]}/resource${var.log_analytics_workspace_id}/logs"
}
