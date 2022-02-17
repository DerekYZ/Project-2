terraform {
  backend "azurerm" {
    resource_group_name  = "Team-1_Project-2_backend"
    storage_account_name = "team1p2storageaccount"
    container_name       = "con"
    key                  = "test-key"
  }
}
