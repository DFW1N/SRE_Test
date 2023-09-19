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

module "virtual_networks" {
depends_on                      = []
    source                      = "../../../main/network/azurerm_virtual_network"
    count                       = 1
    resources                   = var.resources
    main                        = var.main
    virtual_networks            = var.main.virtual_networks
    dateCreated                 = var.dateCreated
    environment                 = var.environment
    managedBy                   = var.managedBy
}