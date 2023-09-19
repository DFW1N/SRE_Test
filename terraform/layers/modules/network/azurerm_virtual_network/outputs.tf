#============================================================================#
#                                                                            #
# ███████╗██████╗ ███╗   ██╗██╗███████╗                                      #
# ██╔════╝██╔══██╗████╗  ██║██║██╔════╝  # Author: Sacha Roussakis-Notter    #
# ███████╗██████╔╝██╔██╗ ██║██║█████╗    # Lisence: MIT                      #
# ╚════██║██╔══██╗██║╚██╗██║██║██╔══╝    # Date Created: 05/07/2022          #
# ███████║██║  ██║██║ ╚████║██║██║       # Framework: SRNIF                  #
# ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝                                           #
# Copyright (c) 2022, Sacha Roussakis-Notter                                 #
#                                                                            #
# ===========================================================================#

output "virtual_network_ids" {
    value = try(module.virtual_networks.virtual_network_ids, null)
}

output "virtual_network_names" {
    value = try(module.virtual_networks.virtual_network_names, null)
}

output "virtual_network_resource_group_names" {
    value = try(module.virtual_networks.virtual_network_resource_group_names, null)
}

output "virtual_network_ddos_protection_ids" {
    value = try(module.virtual_networks.virtual_network_ddos_protection_ids, null)
}