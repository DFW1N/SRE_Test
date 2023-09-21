#============================================================================#
#                                                                            #
#                       Date Created: 21/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

output "kubernetes_cluster_ids" {
    value = try(module.kubernetes_clusters.kubernetes_cluster_ids, null)
}

output "kubernetes_cluster_resource_group_names" {
    value = try(module.kubernetes_clusters.kubernetes_cluster_resource_group_names, null)
}

output "kubernetes_cluster_names" {
    value = try(module.kubernetes_clusters.kubernetes_cluster_names, null)
}