# Primary Resource Group (Malaysia West)
resource "azurerm_resource_group" "primary_rg" {
  name     = "${var.prefix}-${var.environment}-primary-rg"
  location = var.primary_region

  tags = {
    Environment = var.environment
    Role        = "Primary Region"
    Project     = "High Availability"
  }
}

# Secondary Resource Group (Southeast Asia)
resource "azurerm_resource_group" "secondary_rg" {
  provider = azurerm.secondary
  name     = "${var.prefix}-${var.environment}-secondary-rg"
  location = var.secondary_region

  tags = {
    Environment = var.environment
    Role        = "Disaster Recovery Region"
    Project     = "High Availability"
  }
}