#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

###########
# OUTPUTS #
###########

output "network_interface_ids" {
    value = try(azurerm_network_interface.network_interface.id, null)
    description = "Lists the outputs of the Network Interface Id"
}

output "network_interface_private_ip_addresses" {
    value = try(azurerm_network_interface.network_interface.private_ip_addresses, null)
    description = "Lists the outputs of the Network Interface Private IP Addresses"
}

output "network_interface_virtual_machine_id" {
    value = try(azurerm_network_interface.network_interface.virtual_machine_id, null)
    description = "Lists the outputs of the Network Interface Virtual Machine Ids"
}