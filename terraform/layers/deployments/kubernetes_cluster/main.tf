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

module "virtual_networks" {
depends_on                      = [module.resource_groups]
    source                      = "../../../main/network/azurerm_virtual_network"
    count                       = 1
    resources                   = var.resources
    main                        = var.main
    virtual_networks            = var.main.virtual_networks
    dateCreated                 = var.dateCreated
    environment                 = var.environment
    managedBy                   = var.managedBy
}

module "subnets" {
depends_on                      = [module.virtual_networks]
    source                      = "../../../main/network/azurerm_subnet"
    resources                   = var.resources
    main                        = var.main
    special_subnets             = {}
    subnets                     = var.main.subnets
    environment                 = var.environment
    dateCreated                 = var.dateCreated
    managedBy                   = var.managedBy
}

module "linux_virtual_machine" {
depends_on                  = [module.subnets]
    source                  = "../../../main/compute/azurerm_linux_virtual_machine"
    count                   = 1
    resources               = var.resources
    main                    = var.main
    os_settings             = var.resources.virtual_machines.ubuntu
    virtual_machine_map     = var.main.virtual_machines.virtual_machine_1
    virtual_machine_index   = "${format("%01s", count.index + 1)}"
    environment             = var.environment
    dateCreated             = var.dateCreated
    managedBy               = var.managedBy
}