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
        example_1 = {
            location = "australiaeast"
            purpose = "sre"
            identifier = "demo"
            tags = {
                owner = "sacha1777@hotmail.com"
                role = "This resource group is the default config for the module when it is not edited."
            }
        }
        
        example_2 = {
            location = "australiaeast"
            purpose = "sre"
            identifier = "demo2"
            tags = {
                owner = "sacha1777@hotmail.com"
                role = "This resource group is the default config for the module when it is not edited."
            }
        }
    }

    virtual_networks = {
        virtual_network_1 = {
            name = {
                location = "australiaeast"
                purpose = "sre"
                identifier = "demo"
            }
            address_space = ["10.33.84.0/23"]
            dns_servers = ["168.63.129.16"]
            resource_group = {
                location = "australiaeast"
                purpose = "sre"
                identifier = "demo"
            }
            tags = {
                owner = "sacha1777@hotmail.com"
                role = "This virtual network is the default configuration settings for this module."
            }
        }
        virtual_network_2 = {
            name = {
                location = "australiaeast"
                purpose = "sre"
                identifier = "demo"
            }
            address_space = ["10.33.84.0/23"]
            dns_servers = ["168.63.129.16"]
            resource_group = {
                location = "australiaeast"
                purpose = "sre"
                identifier = "demo2"
            }
            tags = {
                owner = "sacha1777@hotmail.com"
                role = "This virtual network is the default configuration settings for this module."
            }
        }
    }

    subnets = {
        subnet_1 = {
            name = {
                purpose = "foo"
                identifier = "demo"
            }
            address_prefix = ["10.33.84.16/28"]
            private_endpoint_network_policies_enabled = true
            private_link_service_network_policies_enabled = true
            service_endpoints = ["Microsoft.Storage"]
            delegations = []
            network_security_group = {
                enable_diagnostic_settings = false
                nsg_inbound_rules = [ ["allow_all", "101", "Inbound", "Allow", "", "*", "*", ""], ]
                nsg_outbound_rules = []
            }
            resource_group = {
                location = "australiaeast"
                purpose = "foo"
                identifier = "demo"
            }
            virtual_network = {
                location = "australiaeast"
                purpose = "foo"
                identifier = "demo"
            }
            routes = {}
        }
    }
}
