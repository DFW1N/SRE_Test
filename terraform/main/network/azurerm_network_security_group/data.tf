#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

##############
# SUBNET MAP #
##############

data "azurerm_subnet" "subnets" {
depends_on = []
    for_each = { for k, v in var.subnets : k => v if lookup(v, "network_security_group", {}) != {} }
    name = format("%s-%s-%s-%s-%s", "${var.resources.resource_types.sntResourceType}", "${each.value.name.purpose}", "${var.environment}", "${local.region_map[coalesce(each.value.virtual_network.location)]}", "${each.value.name.identifier}")
    virtual_network_name = format("%s-%s-%s-%s-%s", "${var.resources.resource_types.vntResourceType}", "${each.value.virtual_network.purpose}", "${var.environment}", "${local.region_map[coalesce(each.value.virtual_network.location)]}", "${each.value.virtual_network.identifier}")
    resource_group_name  = format("%s-%s-%s-%s-%s", "${var.resources.resource_types.rgResourceType}", "${each.value.resource_group.purpose}", "${var.environment}", "${local.region_map[coalesce(each.value.resource_group.location)]}", "${each.value.resource_group.identifier}")
}