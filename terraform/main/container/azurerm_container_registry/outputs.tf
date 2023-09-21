#============================================================================#
#                                                                            #
#                       Date Created: 21/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#


###########
# OUTPUTS #
###########

output "container_registry_ids" {
  value       = flatten([for v in azurerm_container_registry.acr : v.id])
  description = "Lists the outputs of the container registry id's"
}

output "container_registry_resource_group_names" {
  value       = flatten([for n in azurerm_container_registry.acr : n.resource_group_name])
  description = "Lists the outputs of the container registry resource group name"
}

output "container_registry_names" {
  value       = flatten([for n in azurerm_container_registry.acr : n.name])
  description = "Lists the outputs of the container registry names"
}

output "container_registry_admin_username" {
  value       = try(flatten([for v in azurerm_container_registry.acr : v.admin_username]), null)
  description = "Lists the outputs of the container registry administrator usernames"
}

output "container_registry_admin_password" {
  value       = try(flatten([for v in azurerm_container_registry.acr : v.admin_password]), null)
  description = "Lists the outputs of the container registry administrator passwords"
  sensitive   = true
}

output "container_registry_login_server" {
  value       = try(flatten([for v in azurerm_container_registry.acr : v.login_server]), null)
  description = "Lists the outputs of the container registry login server url."
}