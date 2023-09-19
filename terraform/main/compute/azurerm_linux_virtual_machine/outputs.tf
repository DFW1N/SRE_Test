#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

###########
# OUTPUTS #
###########

output "virtual_machine_ids" {
    value = azurerm_linux_virtual_machine.linux.id
    description = "Lists the outputs of the linux virtual machine resource id's"
}

output "virtual_machine_names" {
    value = azurerm_linux_virtual_machine.linux.name
    description = "Lists the outputs of the linux virtual machine names"
}

output "virtual_machine_resource_group_names" {
    value = azurerm_linux_virtual_machine.linux.resource_group_name
    description = "Lists the outputs of the linux virtual machine resource group names"
}

output "network_interface_ids" {
    value = try(module.network_interface.network_interface_ids, null)
    description = "Lists the outputs of the network interface ids"
}