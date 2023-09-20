#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

###########
# OUTPUTS #
###########

output "public_ip_prefix_id" {
    value = azurerm_public_ip_prefix.ip_prefix.id
    description = "Lists the outputs of the Resource Id's"
}

output "public_ip_prefix" {
    value = azurerm_public_ip_prefix.ip_prefix.ip_prefix
    description = "Lists the outputs of the Resource public ip prefix"
}
