#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

main = {

    #####################
    ## RESOURCE GROUPS ##
    #####################

    resource_groups = {
        sre_aks_resource_group = {
            location = "australiaeast"
            purpose = "sre"
            identifier = "aks"
            tags = {
                owner = "sacha1777@hotmail.com"
                role = "This resource group is the default config for the module when it is not edited."
            }
        }
    }

    kubernetes_clusters = {
        kubernetes_cluster_1 = { # <--- Please don't change this value the bash block uses this to extract the naming convention dynamic values.
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
                    identifier = "aks"
                }
                resource_group = {
                    purpose = "sre"
                    identifier = "aks"
                }
                virtual_network = {
                    location = "australiaeast"
                    purpose = "sre"
                    identifier = "aks"
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
                owner = "xxxx@hotmail.com"
                role = "This azure kubernetes cluster is the default configuration settings for this module."
                }
            }
        }
}
