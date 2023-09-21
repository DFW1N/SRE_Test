#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

# This file should be used as an example on how you define the config in the top level .tfvars file on how to deploy a virtual network and relevant configuration attached to it.
  
main = {

    ######################
    ## VIRTUAL NETWORKS ##
    ######################

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
}