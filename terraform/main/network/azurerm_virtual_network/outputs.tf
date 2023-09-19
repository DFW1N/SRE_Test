#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

###########
# OUTPUTS #
###########

output "virtual_network_ids" {
  value       = flatten([for v in azurerm_virtual_network.virtual_network : v.id])
  description = "Lists the outputs of the resource id's"
}

output "virtual_network_names" {
  value       = flatten([for v in azurerm_virtual_network.virtual_network : v.name])
  description = "Lists the outputs of the virtual network names"
}

output "virtual_network_resource_group_names" {
  value       = flatten([for n in azurerm_virtual_network.virtual_network : n.resource_group_name])
  description = "Lists the outputs of the resource group names"
}