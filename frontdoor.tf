# AZURE FRONT DOOR PROFILE (GLOBAL)

resource "azurerm_cdn_frontdoor_profile" "afd" {
  name                = "${var.prefix}-frontdoor"
  resource_group_name = azurerm_resource_group.primary_rg.name
  sku_name            = "Standard_AzureFrontDoor"

  tags = {
    Environment = var.environment
    Role        = "Global Entry Point"
    Project     = "High Availability"
  }
}

# FRONT DOOR ENDPOINT

resource "azurerm_cdn_frontdoor_endpoint" "endpoint" {
  name                     = "${var.prefix}-endpoint-${var.environment}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.afd.id
}

# ORIGIN GROUP & HEALTH PROBES

resource "azurerm_cdn_frontdoor_origin_group" "origin_group" {
  name                     = "${var.prefix}-origin-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.afd.id

  # Health probe configuration to detect regional outages
  health_probe {
    interval_in_seconds = 30
    path                = "/"
    protocol            = "Https"
    request_type        = "HEAD"
  }

  load_balancing {
    additional_latency_in_milliseconds = 50
    sample_size                        = 4
    successful_samples_required        = 2
  }
}

# ORIGIN 1: PRIMARY (Malaysia West)

resource "azurerm_cdn_frontdoor_origin" "primary_origin" {
  name                          = "primary-malaysiawest"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id
  enabled                       = true

  host_name                      = azurerm_linux_web_app.primary_app.default_hostname
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = azurerm_linux_web_app.primary_app.default_hostname
  priority                       = 1
  weight                         = 1000
  certificate_name_check_enabled = true # Required argument
}
# ORIGIN 2: SECONDARY (Southeast Asia)

resource "azurerm_cdn_frontdoor_origin" "secondary_origin" {
  name                          = "secondary-southeastasia"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id
  enabled                       = true

  host_name                      = azurerm_linux_web_app.secondary_app.default_hostname
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = azurerm_linux_web_app.secondary_app.default_hostname
  priority                       = 2
  weight                         = 1000
  certificate_name_check_enabled = true # Required argument
}

# ROUTE CONFIGURATION

resource "azurerm_cdn_frontdoor_route" "route" {
  name                          = "${var.prefix}-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.endpoint.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.origin_group.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.primary_origin.id, azurerm_cdn_frontdoor_origin.secondary_origin.id]

  supported_protocols    = ["Http", "Https"]
  patterns_to_match      = ["/*"]
  forwarding_protocol    = "HttpsOnly"
  link_to_default_domain = true
}

# Output the global Front Door URL for testing
output "front_door_url" {
  value       = "https://${azurerm_cdn_frontdoor_endpoint.endpoint.host_name}"
  description = "The global entry URL managed by Azure Front Door"
}