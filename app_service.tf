# ==========================================
# PRIMARY REGION COMPUTE (Malaysia West)
# ==========================================

resource "azurerm_service_plan" "primary_asp" {
  name                = "${var.prefix}-primary-asp"
  resource_group_name = azurerm_resource_group.primary_rg.name
  location            = azurerm_resource_group.primary_rg.location
  os_type             = "Linux"
  sku_name            = "B1" # Cost-effective Basic tier for testing
}

resource "azurerm_linux_web_app" "primary_app" {
  name                = "${var.prefix}-primary-app-${var.environment}"
  resource_group_name = azurerm_resource_group.primary_rg.name
  location            = azurerm_resource_group.primary_rg.location
  service_plan_id     = azurerm_service_plan.primary_asp.id

  site_config {
    application_stack {
      node_version = "18-lts"
    }
  }

  app_settings = {
    "REGION" = "Malaysia West (Primary)"
  }

  tags = {
    Environment = var.environment
    Role        = "Primary Compute"
  }
}

# ==========================================
# SECONDARY REGION COMPUTE (Southeast Asia)
# ==========================================

resource "azurerm_service_plan" "secondary_asp" {
  provider            = azurerm.secondary
  name                = "${var.prefix}-secondary-asp"
  resource_group_name = azurerm_resource_group.secondary_rg.name
  location            = var.secondary_region
  os_type             = "Linux"
  sku_name            = "B1" # Cost-effective Basic tier for testing
}

resource "azurerm_linux_web_app" "secondary_app" {
  provider            = azurerm.secondary
  name                = "${var.prefix}-secondary-app-${var.environment}"
  resource_group_name = azurerm_resource_group.secondary_rg.name
  location            = var.secondary_region
  service_plan_id     = azurerm_service_plan.secondary_asp.id

  site_config {
    application_stack {
      node_version = "18-lts"
    }
  }

  app_settings = {
    "REGION" = "Southeast Asia (Secondary/DR)"
  }

  tags = {
    Environment = var.environment
    Role        = "Secondary Compute"
  }
}