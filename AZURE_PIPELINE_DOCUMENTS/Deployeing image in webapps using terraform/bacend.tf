terraform {
  backend "azurerm" {
    resource_group_name  = "navya"
    storage_account_name = "forrestorebackup"
    container_name       = "murali"
    key                  = "tejasiri"
  }
}