#============================================================================#
#                                                                            #
#                       Date Created: 21/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

module "azure_container_registries" {
depends_on                      = []
    source                      = "../../../../main/container/azurerm_container_registry"
    resources                   = var.resources
    main                        = var.main
    container_registries        = var.main.container_registries
    environment                 = var.environment
    dateCreated                 = var.dateCreated
    managedBy                   = var.managedBy
}