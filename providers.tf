terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

# Primary Region Provider (Malaysia West)
provider "azurerm" {
  features {}
}

# Secondary Region Provider (Southeast Asia) - Aliased for DR
provider "azurerm" {
  alias   = "secondary"
  features {}
}