#============================================================================#
#                                                                            #
#                       Date Created: 21/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

main = {

    ##############################
    ## AZURE CONTAINER REGISTRY ##
    ##############################

    container_registries = {
        container_registry_1 = {
            name = {
                purpose = "sre"
                identifier = "aks"
            }
            
            resource_group = {
                location = "australiaeast"
                purpose = "sre"
                identifier = "aks"
            }

            tags = {
                owner = "sacha1777@hotmail.com"
                role = "This azure container registry is the default configuration settings for this module."
            }

            settings = {
                sku = "Premium"
                admin_enabled = false
                public_network_access_enabled = true
                quarantine_policy_enabled = false
                export_policy_enabled = true
                zone_redundancy_enabled = false
                anonymous_pull_enabled = true
                data_endpoint_enabled = false
                network_rule_bypass_option = "AzureServices"
            }

            identity = {
                type = "SystemAssigned"
            }
        }
    }
}