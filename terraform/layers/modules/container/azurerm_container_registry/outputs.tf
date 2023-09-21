#============================================================================#
#                                                                            #
# ███████╗██████╗ ███╗   ██╗██╗███████╗                                      #
# ██╔════╝██╔══██╗████╗  ██║██║██╔════╝  # Author: Sacha Roussakis-Notter    #
# ███████╗██████╔╝██╔██╗ ██║██║█████╗    # Lisence: MIT                      #
# ╚════██║██╔══██╗██║╚██╗██║██║██╔══╝    # Date Created: 09/09/2022          #
# ███████║██║  ██║██║ ╚████║██║██║       # Framework: SRNIF                  #
# ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝                                           #
# Copyright (c) 2022, Sacha Roussakis-Notter                                 #
#                                                                            #
# ===========================================================================#

output "container_registry_ids" {
    value = try(module.azure_container_registries.container_registry_ids, null)
}

output "container_registry_resource_group_names" {
    value = try(module.azure_container_registries.container_registry_resource_group_names, null)
}

output "container_registry_names" {
    value = try(module.azure_container_registries.container_registry_names, null)
}

output "container_registry_admin_username" {
    value = try(module.azure_container_registries.container_registry_admin_username, null)
}

output "container_registry_admin_password" {
    value = try(module.azure_container_registries.container_registry_admin_password, null)
}

output "container_registry_login_server" {
    value = try(module.azure_container_registries.container_registry_login_server, null)
}