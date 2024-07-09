provider "azurerm" {
  features {}
}

# Storage account

resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_account_replication_type
}

# Containers in the Storage Account 

resource "azurerm_storage_container" "container" {
  count                 = length(var.container_names)
  name                  = var.container_names[count.index]
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

# Event Grid Namespace

# Create an Event Grid Namespace
resource "azurerm_eventgrid_domain" "event_grid_namespace" {
  name                = var.event_grid_namespace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  public_network_access_enabled = true
}


