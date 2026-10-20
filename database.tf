# ==========================================
# SQL SERVER 1: PRIMARY (Malaysia West)
# ==========================================

resource "azurerm_mssql_server" "primary_sql" {
  name                         = "${var.prefix}-primary-sqlserver"
  resource_group_name          = azurerm_resource_group.primary_rg.name
  location                     = azurerm_resource_group.primary_rg.location
  version                      = "12.0"
  administrator_login          = "sqladminuser"
  administrator_login_password = "P@ssword123456789!"

  tags = {
    Environment = var.environment
    Role        = "Primary SQL Server"
  }
}

# ==========================================
# SQL SERVER 2: SECONDARY (Southeast Asia)
# ==========================================

resource "azurerm_mssql_server" "secondary_sql" {
  provider                     = azurerm.secondary
  name                         = "${var.prefix}-secondary-sqlserver"
  resource_group_name          = azurerm_resource_group.secondary_rg.name
  location                     = var.secondary_region
  version                      = "12.0"
  administrator_login          = "sqladminuser"
  administrator_login_password = "P@ssword123456789!"

  tags = {
    Environment = var.environment
    Role        = "Secondary SQL Server"
  }
}

# ==========================================
# PRIMARY AZURE SQL DATABASE
# ==========================================

resource "azurerm_mssql_database" "db" {
  name                 = "${var.prefix}-db"
  server_id            = azurerm_mssql_server.primary_sql.id
  sku_name             = "S0" # Standard tier (Cost-effective for HA testing)
  max_size_gb          = 10
  storage_account_type = "Local" # Uses LRS backups to bypass region GRS restriction

  tags = {
    Environment = var.environment
    Role        = "Primary Database"
  }
}

# ==========================================
# FAILOVER GROUP (AUTOMATED DR)
# ==========================================

resource "azurerm_mssql_failover_group" "failover" {
  name      = "${var.prefix}-failover-group"
  server_id = azurerm_mssql_server.primary_sql.id
  databases = [
    azurerm_mssql_database.db.id
  ]

  partner_server {
    id = azurerm_mssql_server.secondary_sql.id
  }

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 60
  }

  tags = {
    Environment = var.environment
    Role        = "Database Failover Group"
  }
}

#run failover thru bash