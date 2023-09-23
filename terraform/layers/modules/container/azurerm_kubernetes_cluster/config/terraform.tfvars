#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

main = {

    #########################
    ## KUBERNETES CLUSTERS ##
    #########################

    kubernetes_clusters = {
        kubernetes_cluster_1 = {
            name = {
                purpose = "sre"
                identifier = "demo"
            }
            resource_group = {
                location = "australiaeast"
                purpose = "sre"
                identifier = "aks"
            }
            subnet = {
                name = {
                    purpose = "sre"
                    identifier = "demo"
                }
                resource_group = {
                    purpose = "sre"
                    identifier = "aks"
                }
                virtual_network = {
                    location = "australiaeast"
                    purpose = "sre"
                    identifier = "demo"
                }
            }
            settings = {
                admin_username = "aksadmin"
                kubernetes_version = "1.22"
                dns_prefix = "ldo"
                sku_tier = "Free"
                private_cluster_enabled = false
                identity_type = "SystemAssigned"
                role_based_access_control_enabled = true
            }
            tags = {
                owner = "sacha1777@hotmail.com"
                role = "This azure kubernetes cluster is the default configuration settings for this module."
                }
            }
        }
    }