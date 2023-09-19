#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

###########
# OUTPUTS #
###########

output "azure_resource_group_ids" {
    value = flatten([ for v in azurerm_resource_group.resource_groups : v.id])
    description = "Lists the outputs of the Resource Group Id's"
}

output "azure_resource_group_names" {
    value = flatten([ for n in azurerm_resource_group.resource_groups : n.name])
    description = "Lists the outputs of the resource group name"
}
