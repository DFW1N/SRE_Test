#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

locals {
    resource_group = format("%s-%s-%s-%s-%s", "${var.resources.resource_types.rgResourceType}", "${var.resource_group.purpose}", "${var.environment}", "${local.region_map[coalesce(var.resource_group.location)]}", "${var.resource_group.identifier}")
    region_map = tomap({
        for k, v in var.resources.azure_locations.regions : k => v
    })
}