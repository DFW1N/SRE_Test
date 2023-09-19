#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

######################
# RESOURCE GROUP MAP #
######################

data "azurerm_resource_group" "resource_group" {
depends_on = []
    count = lookup(var.virtual_machine_map, "resource_group", {}) != {} ? 1 : 0
    name = try(format("%s-%s-%s-%s-%s", "${var.resources.resource_types.rgResourceType}", "${var.virtual_machine_map.resource_group.purpose}", "${var.environment}", "${local.region_map[coalesce(var.virtual_machine_map.resource_group.location)]}", "${var.virtual_machine_map.resource_group.identifier}"), null)
}