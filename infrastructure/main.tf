terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  use_oidc = true
}
resource "azurerm_resource_group" "demo_rg" {
  name     = var.resource_group_name
  location = var.location

}
resource "azurerm_resource_group" "aks_demo_rg" {
  name     = var.aks_resource_group_name
  location = var.location

}
module "ServicePrincipal" {
  source                 = "./modules/ServicePrincipal"
  service_principal_name = var.service_principal_name
  depends_on = [
    azurerm_resource_group.demo_rg
  ]
}
resource "azurerm_role_assignment" "rolespn" {

  scope                = "/subscriptions/245140cf-eeea-4def-9e7f-f42e9d0e701a"
  role_definition_name = "Owner"
  principal_id         = module.ServicePrincipal.service_principal_object_id

  depends_on = [
    module.ServicePrincipal
  ]
}

resource "azurerm_role_assignment" "key_vault_admin" {
  scope                = module.keyvault.keyvault_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = module.ServicePrincipal.service_principal_object_id

  depends_on = [
    module.ServicePrincipal,
    module.keyvault
  ]
}
module "keyvault" {
  source                      = "./modules/keyvault"
  keyvault_name               = var.keyvault_name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  service_principal_name      = var.service_principal_name
  service_principal_object_id = module.ServicePrincipal.service_principal_object_id
  service_principal_tenant_id = module.ServicePrincipal.service_principal_tenant_id

  depends_on = [
    module.ServicePrincipal
  ]
}
resource "azurerm_key_vault_secret" "example" {
  name         = module.ServicePrincipal.service_principal_object_id
  value        = module.ServicePrincipal.client_secret
  key_vault_id = module.keyvault.keyvault_id

  depends_on = [
    module.keyvault
  ]
}
resource "azurerm_container_registry" "acr" {
  name                = var.acr
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
  depends_on = [
    azurerm_resource_group.demo_rg
  ]
}
resource "azurerm_role_assignment" "example" {
  principal_id                     = module.ServicePrincipal.service_principal_object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}
#create Azure Kubernetes Service
# module "aks" {
#   source                  = "./modules/aks/"
#   service_principal_name  = var.service_principal_name
#   client_id               = var.client_id
#   client_secret           = module.ServicePrincipal.client_secret
#   location                = var.location
#   aks_resource_group_name = var.aks_resource_group_name

#   depends_on = [
#     module.ServicePrincipal
#   ]

# }