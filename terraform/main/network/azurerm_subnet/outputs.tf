#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

###########
# OUTPUTS #
###########

output "subnet_ids" {
    value = flatten([ for v in azurerm_subnet.subnets : v.id])
    description = "Lists the outputs of the subnet ids"
}

output "subnet_names" {
    value = flatten([ for v in azurerm_subnet.subnets : v.name])
    description = "Lists the outputs of the virtual network subnet names"
}

output "subnet_virtual_network_names" {
    value = flatten([ for v in azurerm_subnet.subnets : v.virtual_network_name])
    description = "Lists the outputs of the subnet virtual network names"
}

output "subnet_resource_group_names" {
    value = flatten([ for v in azurerm_subnet.subnets : v.resource_group_name])
    description = "Lists the outputs of the subnet resource group names"
}