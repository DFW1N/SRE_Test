#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

module "subnets" {
depends_on                      = []
    source                      = "../../../main/network/azurerm_subnet"
    resources                   = var.resources
    main                        = var.main
    special_subnets             = try(var.main.special_subnets, null)
    subnets                     = var.main.subnets
    environment                 = var.environment
    dateCreated                 = var.dateCreated
    managedBy                   = var.managedBy
}