locals {
  # Base naming pattern: prefix-resourcetype-environment-suffix
  # Examples:
  #   - rg-myapp-sandbox-001
  #   - st-myapp-prod-data
  #   - vnet-myapp-dev-hub

  base_name = var.suffix != "" ? "${var.prefix}-${var.environment}-${var.suffix}" : "${var.prefix}-${var.environment}"

  # Azure resource type abbreviations (following Microsoft CAF naming conventions)
  # Reference: https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations

  resource_group          = "rg-${local.base_name}"
  storage_account         = lower(replace("st${var.prefix}${var.environment}${var.suffix}", "-", "")) # Storage accounts: lowercase, no hyphens
  virtual_network         = "vnet-${local.base_name}"
  subnet                  = "snet-${local.base_name}"
  network_security_group  = "nsg-${local.base_name}"
  public_ip               = "pip-${local.base_name}"
  load_balancer           = "lb-${local.base_name}"
  virtual_machine         = "vm-${local.base_name}"
  key_vault               = lower(replace("kv-${var.prefix}-${var.environment}", "-", "")) # Key Vault: lowercase, no hyphens, max 24 chars
  app_service             = "app-${local.base_name}"
  function_app            = "func-${local.base_name}"
  sql_server              = lower("sql-${local.base_name}")
  cosmos_db               = lower("cosmos-${local.base_name}")
  aks_cluster             = "aks-${local.base_name}"
  container_registry      = lower(replace("acr${var.prefix}${var.environment}", "-", "")) # ACR: lowercase, alphanumeric only
  app_insights            = "appi-${local.base_name}"
  log_analytics_workspace = "log-${local.base_name}"
}

