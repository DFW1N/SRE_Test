#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

module "virtual_networks" {
depends_on                      = []
    source                      = "../../../main/network/azurerm_virtual_network"
    resources                   = var.resources
    main                        = var.main
    virtual_networks            = var.main.virtual_networks
    dateCreated                 = var.dateCreated
    environment                 = var.environment
    managedBy                   = var.managedBy
}