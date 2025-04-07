provider "azurerm" {
  features {}
}

resource "random_pet" "storage_account_name" {
  length = 3
}

resource "azurerm_resource_group" "example" {
  name     = "azurebootcamp"
  location = "West Europe"
}

resource "azurerm_storage_account" "example" {
  name                     = random_pet.storage_account_name.id
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "example"
  }
}
