#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

######################
# SUBNET DATA IMPORT #
######################

data "azurerm_subnet" "subnet" {
depends_on = []
    name = format("%s-%s-%s-%s-%s", "${var.resources.resource_types.sntResourceType}", "${var.subnet.name.purpose}", "${var.environment}", "${local.region_map[coalesce(var.subnet.virtual_network.location)]}", "${var.subnet.name.identifier}")
    virtual_network_name = format("%s-%s-%s-%s-%s", "${var.resources.resource_types.vntResourceType}", "${var.subnet.virtual_network.purpose}", "${var.environment}", "${local.region_map[coalesce(var.subnet.virtual_network.location)]}", "${var.subnet.virtual_network.identifier}")
    resource_group_name = format("%s-%s-%s-%s-%s", "${var.resources.resource_types.rgResourceType}", "${var.subnet.resource_group.purpose}", "${var.environment}", "${local.region_map[coalesce(var.subnet.resource_group.location)]}", "${var.subnet.resource_group.identifier}")
}

data "azurerm_resource_group" "resource_group" {
depends_on = []
    count = lookup(var.virtual_machine_map, "resource_group", {}) != {} ? 1 : 0
    name = try(format("%s-%s-%s-%s-%s", "${var.resources.resource_types.rgResourceType}", "${var.virtual_machine_map.resource_group.purpose}", "${var.environment}", "${local.region_map[coalesce(var.virtual_machine_map.resource_group.location)]}", "${var.virtual_machine_map.resource_group.identifier}"), null)
}