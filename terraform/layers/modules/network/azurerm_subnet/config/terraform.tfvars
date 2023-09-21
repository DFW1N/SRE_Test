#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

# This file should be used as an example on how you define the config in the top level .tfvars file on how to deploy a virtual network and relevant configuration attached to it.
  
main = {

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
                nsg_inbound_rules = [ ["allow_all", "101", "Inbound", "Allow", "", "*", "*", ""], ]
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

  }
