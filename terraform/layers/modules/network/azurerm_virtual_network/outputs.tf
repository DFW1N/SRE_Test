#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

output "virtual_network_ids" {
    value = try(module.virtual_networks.virtual_network_ids, null)
}

output "virtual_network_names" {
    value = try(module.virtual_networks.virtual_network_names, null)
}

output "virtual_network_resource_group_names" {
    value = try(module.virtual_networks.virtual_network_resource_group_names, null)
}

output "virtual_network_ddos_protection_ids" {
    value = try(module.virtual_networks.virtual_network_ddos_protection_ids, null)
}