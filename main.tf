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

variable rgname { type = string}
variable location { type = string}

resource "azurerm_resource_group" "myrg" {
  name     = var.resource_group_name
  location = var.resource_location
}

resource "azurerm_resource_group" "remotestaterg" {
  name = var.rgname
  location = var.location
}

resource "azurerm_storage_account" "tfazlearningrsstorage" {
  name = "tfazlearningrsstorage"
  resource_group_name = azurerm_resource_group.remotestaterg.name
  location = azurerm_resource_group.remotestaterg.location
  account_tier = "Standard"
  account_replication_type = "GRS"

  tags = {
    "environment" = "staging"
  }
}

resource "azurerm_storage_container" "remotestate-container" {
  name                  = "statefiles"
  storage_account_name  = azurerm_storage_account.tfazlearningrsstorage.name
  container_access_type = "private"
}

data "azurerm_storage_account_sas" "storage-sas" {
  connection_string = azurerm_storage_account.tfazlearningrsstorage.primary_connection_string
  https_only        = true

  start  = "2023-01-30"
  expiry = "2023-10-20"

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

    resource_types {
    service   = true
    container = true
    object    = true
  }

   permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = true
    process = true
    filter  = true
    tag     = true
  }

}

data "azurerm_storage_account_blob_container_sas" "container-sas" {
  connection_string = azurerm_storage_account.tfazlearningrsstorage.primary_connection_string
  container_name    = azurerm_storage_container.remotestate-container.name
  https_only        = true

  start  = "2023-01-30"
  expiry = "2023-10-20"

  permissions {
    read   = true
    add    = true
    create = true
    write  = true
    delete = true
    list   = true
  }

  cache_control       = "max-age=5"
  content_disposition = "inline"
  content_encoding    = "deflate"
  content_language    = "en-US"
  content_type        = "application/json"
}

output "sas_container_query_string" {
  value = data.azurerm_storage_account_blob_container_sas.container-sas.sas
  sensitive = true
}

output "sas_storage_query_string" {
  value = data.azurerm_storage_account_sas.storage-sas.sas
  sensitive = true
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
    sensitive = true
}
