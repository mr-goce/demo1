variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type    = string
  default = "West Europe"

}
variable "service_principal_name" {
  type = string

}
variable "keyvault_name" {
  type = string

}
variable "acr" {
  type = string
}
variable "backendsa" {
  type = string
}
variable "backendcontainer" {
  type = string
}
variable "aks_resource_group_name" {
  type        = string
  description = "AKS Resource group name"
}

variable "client_id" {
  type = string
}