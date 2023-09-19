#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

####################
# PUBLIC IP MODULE #
####################

module "public_ips" {
depends_on              = []
    count               = var.virtual_machine_map.attach_public_ip == true ? 1 : 0
    source              = "../../network/azurerm_public_ip"
    resources           = var.resources
    location            = var.virtual_machine_map.resource_group.location
    main                = var.main
    environment         = var.environment
    dateCreated         = var.dateCreated
    managedBy           = var.managedBy
    resource_group      = format("%s-%s-%s-%s-%s", "${var.resources.resource_types.rgResourceType}", "${var.virtual_machine_map.resource_group.purpose}", "${var.environment}", "${local.region_map[coalesce(var.virtual_machine_map.resource_group.location)]}", "${var.virtual_machine_map.resource_group.identifier}")
    resource_name       = local.virtual_machine_name
    resource_map        = var.virtual_machine_map
}

############################
# NETWORK INTERFACE MODULE #
############################

module "network_interface" {
depends_on               = [module.public_ips]
    source               = "../../network/azurerm_network_interface"
    resources            = var.resources
    environment          = var.environment
    dateCreated          = var.dateCreated
    managedBy            = var.managedBy
    subnet               = var.virtual_machine_map.subnet
    resource_group       = var.virtual_machine_map.resource_group
    resource_name        = local.virtual_machine_name
    resource_map         = var.virtual_machine_map
}
