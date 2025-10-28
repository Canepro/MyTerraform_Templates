terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

resource "azurerm_service_plan" "this" {
  name                = "${var.name}-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.sku_name

  tags = var.tags
}

resource "azurerm_linux_web_app" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.this.id

  site_config {
    always_on        = var.always_on
    ftps_state       = "FtpsOnly"
    http2_enabled    = true
    minimum_tls_version = "1.2"

    dynamic "application_stack" {
      for_each = var.application_stack != null ? [var.application_stack] : []
      content {
        docker_image        = lookup(application_stack.value, "docker_image", null)
        docker_image_tag    = lookup(application_stack.value, "docker_image_tag", null)
        node_version        = lookup(application_stack.value, "node_version", null)
        python_version      = lookup(application_stack.value, "python_version", null)
        dotnet_version      = lookup(application_stack.value, "dotnet_version", null)
      }
    }
  }

  app_settings = var.app_settings

  https_only = true

  tags = var.tags
}

