terraform {
  required_version = "~>v1.1.6"
  required_providers {
    azurerm = {
      version = "~> 3.41.0"
      source = "hashicorp/azurerm"
    }
  }
}