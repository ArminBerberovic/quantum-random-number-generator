terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.113.0"
    }
    azapi = {
      source = "Azure/azapi"
      version = "1.14.0"
    }
  }

  required_version = ">= 1.9.2"
}