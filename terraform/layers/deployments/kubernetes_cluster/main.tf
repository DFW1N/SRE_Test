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

module "azure_kubernetes_clusters" {
depends_on                      = [module.resource_groups]
    source                      = "../../../main/container/azurerm_kubernetes_cluster"
    count                       = 1
    resources                   = var.resources
    main                        = var.main
    kubernetes_cluster          = var.main.kubernetes_clusters.kubernetes_cluster_1
    environment                 = var.environment
    dateCreated                 = var.dateCreated
    managedBy                   = var.managedBy
    ssh_public_key              = var.ssh_public_key
}