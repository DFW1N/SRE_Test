#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

module "resource_groups" {
depends_on                      = []
    source                      = "../../../main/base/azurerm_resource_group"
    resources                   = var.resources
    resource_groups             = var.main.resource_groups
    dateCreated                 = var.dateCreated
    environment                 = var.environment
    managedBy                   = var.managedBy
}

module "virtual_networks" {
depends_on                      = [module.resource_groups]
    source                      = "../../../main/network/azurerm_virtual_network"
    count                       = 1
    resources                   = var.resources
    main                        = var.main
    virtual_networks            = var.main.virtual_networks
    dateCreated                 = var.dateCreated
    environment                 = var.environment
    managedBy                   = var.managedBy
}