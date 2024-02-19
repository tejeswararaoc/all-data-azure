terraform {
  backend "azurerm" {
    resource_group_name  = "srinivas-RG"
    storage_account_name = "mypracticeaccountstorage"
    container_name       = "filesstoragecontainer"
    key                  = "terraform.tfstate"
  }
}