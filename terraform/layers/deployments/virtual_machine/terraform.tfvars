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
                owner = "xxxx@hotmail.com"
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
                owner = "xxxx@hotmail.com"
                role = "This virtual network is the default configuration settings for this module."
            }
        }
    }

    subnets = {
        subnet_1 = {
            name = {
                purpose = "sre"
                identifier = "demo"
            }
            address_prefix = ["10.33.84.16/28"]
            private_endpoint_network_policies_enabled = true
            private_link_service_network_policies_enabled = true
            service_endpoints = ["Microsoft.Storage"]
            delegations = []
            network_security_group = {
                enable_diagnostic_settings = false
                nsg_inbound_rules = [ ["allow_http", "101", "Inbound", "Allow", "", "80", "*", ""], ["allow_https", "102", "Inbound", "Allow", "", "443", "*", ""], ["allow_ssh", "103", "Inbound", "Allow", "", "22", "*", ""] ]
                nsg_outbound_rules = []
            }
            resource_group = {
                location = "australiaeast"
                purpose = "sre"
                identifier = "demo"
            }
            virtual_network = {
                location = "australiaeast"
                purpose = "sre"
                identifier = "demo"
            }
            routes = {}
        }
    }

    linux_virtual_machine_scale_sets = {
        linux_scale_set_1 = { # <--- Please don't change this value the bash block uses this to extract the naming convention dynamic values.
            name = {
                purpose = "sre"
                identifier = "ubu"
            }
            resource_group = {
                location = "australiaeast"
                purpose = "sre"
                identifier = "demo"
            }
            attach_public_ip = true
            use_ssh_authentication = true
            settings = {
                instances = 1
                username = "adminuser"
                size = "Standard_D2_v3"
            }
            cloudinit = {
                enable = true
                web_server = {
                    enable_ngnix = true
                }
            }
            
            tags = {
                owner = "xxxx@hotmail.com"
                role = "This virtual machine scale set is the default configuration settings for this module."
            }
        }
    }
}
