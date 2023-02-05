provider "azurerm" {
  subscription_id = var.azure_subscription_id
  tenant_id = var.azure_tenant_id
  client_id = var.azure_client_id
  client_secret = var.azure_client_secret
  #displayName": "azure-cli-2023-02-02-23-00-31"
    features {}
}