#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

output "subnet_ids" {
    value = try(module.subnets.subnet_ids, null)
}

output "subnet_names" {
    value = try(module.subnets.subnet_names, null)
}

output "subnet_virtual_network_names" {
    value = try(module.subnets.subnet_virtual_network_names, null)
}

output "subnet_resource_group" {
    value = try(module.subnets.subnet_resource_group_names, null)
}
