#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

###########
# OUTPUTS #
###########

output "linux_scale_set_ids" {
    value = azurerm_linux_virtual_machine_scale_set.linux_scale_set.id
    description = "Lists the outputs of the Resource Id's"
}

output "public_ip_prefix" {
    value = try(module.public_ip_prefix[0].public_ip_prefix, null)
    description = "Lists the outputs of the public ip prefix"
}

output "linux_scale_set_resource_group_name" {
    value = azurerm_linux_virtual_machine_scale_set.linux_scale_set.resource_group_name
    description = "Lists the outputs of the Resource group name"
}
