terraform {
    required_version = "~>v1.1.6"
    required_providers {
    azurerm = {
      version = "~> 3.41.0"
      source = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  subscription_id = var.azure_subscription_id
  tenant_id = var.azure_tenant_id
  client_id = var.azure_client_id
  client_secret = var.azure_client_secret
  #displayName": "azure-cli-2023-02-02-23-00-31"
    features {}
}

variable resource_group_name {
    type = string
    description = "the name of resource group for containing resources"
}

variable resource_location {
    type = string
    description = "azure location for hosting resources"
}

variable storage_account_name {
    type = string
    description = "the name of Azure storage account"
}

resource "azurerm_resource_group" "myrg" {
  name     = var.resource_group_name
  location = var.resource_location
}

resource "azurerm_storage_account" "mystorage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.myrg.name
  location                 = azurerm_resource_group.myrg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "test"
  }
}
output resource_group_details {
    value = azurerm_resource_group.myrg
}

output storage_account_details {
    value = azurerm_storage_account.mystorage
}
