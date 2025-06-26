# modules/monitoring/main.tf

# Use existing Log Analytics Workspace
data "azurerm_log_analytics_workspace" "main" {
  name                = split("/", var.log_analytics_workspace_id)[8]
  resource_group_name = var.resource_group
}

# Application Insights - Application performance monitoring
resource "azurerm_application_insights" "main" {
  name                = var.application_insights_name
  location            = var.location
  resource_group_name = var.resource_group
  application_type    = "web"
  workspace_id        = var.log_analytics_workspace_id

  tags = var.tags
}

# Action Group for alerts
resource "azurerm_monitor_action_group" "main" {
  name                = "aks-monitoring-alerts"
  resource_group_name = var.resource_group
  short_name          = "aksdemo"

  dynamic "email_receiver" {
    for_each = var.alert_email != "" ? [1] : []
    content {
      name          = "admin-email"
      email_address = var.alert_email
    }
  }

  tags = var.tags
}

# AKS Node CPU Usage Alert
resource "azurerm_monitor_metric_alert" "aks_node_cpu" {
  name                = "aks-node-cpu-high"
  resource_group_name = var.resource_group
  scopes              = [var.aks_cluster_id]
  description         = "Alert when AKS node CPU usage is high"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_cpu_usage_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

# AKS Node Memory Usage Alert
resource "azurerm_monitor_metric_alert" "aks_node_memory" {
  name                = "aks-node-memory-high"
  resource_group_name = var.resource_group
  scopes              = [var.aks_cluster_id]
  description         = "Alert when AKS node memory usage is high"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "node_memory_working_set_percentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 85
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

# Pod Ready Alert
resource "azurerm_monitor_metric_alert" "pod_ready" {
  name                = "aks-pod-not-ready"
  resource_group_name = var.resource_group
  scopes              = [var.aks_cluster_id]
  description         = "Alert when pods are not ready"
  severity            = 3
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.ContainerService/managedClusters"
    metric_name      = "kube_pod_status_ready"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 1

    dimension {
      name     = "condition"
      operator = "Include"
      values   = ["true"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

# Container Registry Login Alert
resource "azurerm_monitor_metric_alert" "acr_failed_logins" {
  name                = "acr-failed-logins"
  resource_group_name = var.resource_group
  scopes              = [var.acr_id]
  description         = "Alert on failed ACR login attempts"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.ContainerRegistry/registries"
    metric_name      = "TotalPullCount"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 10
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

# Diagnostic Settings for AKS
resource "azurerm_monitor_diagnostic_setting" "aks" {
  name                       = "aks-diagnostics"
  target_resource_id         = var.aks_cluster_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # AKS Control Plane Logs
  enabled_log {
    category = "kube-apiserver"
  }

  enabled_log {
    category = "kube-audit"
  }

  enabled_log {
    category = "kube-audit-admin"
  }

  enabled_log {
    category = "kube-controller-manager"
  }

  enabled_log {
    category = "kube-scheduler"
  }

  enabled_log {
    category = "cluster-autoscaler"
  }

  enabled_log {
    category = "guard"
  }

  # AKS Metrics
  enabled_metric {
    category = "AllMetrics"
  }
}

# Diagnostic Settings for ACR
resource "azurerm_monitor_diagnostic_setting" "acr" {
  name                       = "acr-diagnostics"
  target_resource_id         = var.acr_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ContainerRegistryRepositoryEvents"
  }

  enabled_log {
    category = "ContainerRegistryLoginEvents"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# Diagnostic Settings for Key Vault
resource "azurerm_monitor_diagnostic_setting" "keyvault" {
  name                       = "keyvault-diagnostics"
  target_resource_id         = var.key_vault_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# Workbook for AKS Monitoring (Custom Dashboard)
resource "azurerm_application_insights_workbook" "aks_monitoring" {
  name                = "12345678-1234-1234-1234-123456789012"
  resource_group_name = var.resource_group
  location            = var.location
  display_name        = "AKS Monitoring Dashboard"
  source_id           = lower(var.log_analytics_workspace_id)

  # Workbook template with common AKS monitoring queries
  data_json = jsonencode({
    version = "Notebook/1.0"
    items = [
      {
        type = 3
        content = {
          version = "KqlItem/1.0"
          query = "Perf | where ObjectName == \"K8SNode\" | where CounterName == \"cpuUsageNanoCores\" | summarize avg(CounterValue) by Computer"
          size = 1
          title = "Node CPU Usage"
          timeContext = {
            durationMs = 3600000
          }
          queryType = 0
          resourceType = "microsoft.operationalinsights/workspaces"
        }
      }
    ]
  })

  tags = var.tags
}
