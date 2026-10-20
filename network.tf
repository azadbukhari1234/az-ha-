# Primary region
resource "azurerm_virtual_network" "primary_vnet" {
    name  = "${var.prefix}-primary-vnet"
    address_space = ["10.1.0.0/16"]
    location = azurerm_resource_group.primary_rg.location
    resource_group_name = azurerm_resource_group.primary_rg.name

    tags = {
        Environment = var.environment
        Role ="Primary Region"
    }
}

resource "azurerm_subnet" "primary_subnet" {
    name = "${var.prefix}-primary-subnet"
    resource_group_name = azurerm_resource_group.primary_rg.name
    virtual_network_name = azurerm_virtual_network.primary_vnet.name
    address_prefixes = ["10.1.1.0/24"]
}

resource "azurerm_virtual_network" "secondary_vnet" {
  provider            = azurerm.secondary
  name                = "${var.prefix}-secondary-vnet"
  address_space       = ["10.2.0.0/16"]
  location            = var.secondary_region
  resource_group_name = azurerm_resource_group.secondary_rg.name

  tags = {
    Environment = var.environment
    Role        = "Secondary VNet"
  }
}

resource "azurerm_subnet" "secondary_subnet" {
  provider             = azurerm.secondary
  name                 = "${var.prefix}-secondary-subnet"
  resource_group_name  = azurerm_resource_group.secondary_rg.name
  virtual_network_name = azurerm_virtual_network.secondary_vnet.name
  address_prefixes     = ["10.2.1.0/24"]
}