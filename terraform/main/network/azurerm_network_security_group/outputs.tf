#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

###########
# OUTPUTS #
###########

output "network_security_groups_ids" {
    value = flatten([ for v in azurerm_network_security_group.network_security_groups : v.id])
    description = "Lists the outputs of the Resource Id's"
}

output "network_security_groups_resource_group_names" {
    value = flatten([ for n in azurerm_network_security_group.network_security_groups : n.name])
    description = "Lists the outputs of the Resource Group Names"
}
