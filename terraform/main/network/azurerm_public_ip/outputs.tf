#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

###########
# OUTPUTS #
###########

output "public_ip_ids" {
    value = try(azurerm_public_ip.public_ip.id, null)
    description = "Lists the outputs of the Public IP Address Ids"
}

output "public_ip_addresses" {
    value = try(azurerm_public_ip.public_ip.ip_address, null)
    description = "Lists the outputs of the Public IP Addresses"
}

output "public_ip_name" {
    value = try(azurerm_public_ip.public_ip.name, null)
    description = "Lists the outputs of the Public IP Names"
}

output "public_ip_resource_group_name" {
    value = try(azurerm_public_ip.public_ip.resource_group_name, null)
    description = "Lists the outputs of the Public IP Resource Group Names"
}