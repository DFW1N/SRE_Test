#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

output "resource_group_ids" {
    value = try(module.resource_groups.azure_resource_group_ids, null)
}

output "resource_group_names" {
    value = try(module.resource_groups.azure_resource_group_names, null)
}
