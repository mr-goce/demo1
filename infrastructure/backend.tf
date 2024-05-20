terraform {
  backend "azurerm" {
    resource_group_name  = "demo_rg"
    storage_account_name = "devstaccount0101984"
    container_name       = "dev-terraform"
    key                  = "prod.terraform.tfstate"
  }
}