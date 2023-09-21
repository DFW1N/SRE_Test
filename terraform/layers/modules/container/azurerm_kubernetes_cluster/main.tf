#============================================================================#
#                                                                            #
#                       Date Created: 21/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

module "azure_kubernetes_clusters" {
depends_on                      = []
    source                      = "../../../../main/container/azurerm_kubernetes_cluster"
    count                       = 1
    resources                   = var.resources
    main                        = var.main
    kubernetes_cluster          = var.main.kubernetes_clusters.kubernetes_cluster_1
    environment                 = var.environment
    dateCreated                 = var.dateCreated
    managedBy                   = var.managedBy
}