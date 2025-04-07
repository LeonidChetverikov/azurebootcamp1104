provider "azurerm" {
  features {}
}

resource "random_pet" "storage_account_name" {
  length = 3
}

resource "random_string" "storage_name" {
  length    = 12
  upper     = false
  special   = false
}

resource "azurerm_storage_account" "azbootcamp" {
  name                     = random_string.storage_name.result
  resource_group_name      = "azurebootcamp"
  location                 = "West Europe"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "azbootcamp"
  }
}
