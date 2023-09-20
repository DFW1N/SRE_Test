#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

locals {
    virtual_machine_scale_set_name = format("%s%s%s%s%s%s", "${var.resources.resource_types.vmResourceType}", "${var.virtual_machine_map.name.purpose}", "${var.environment}", "${local.vm_region_map[coalesce(var.virtual_machine_map.resource_group.location)]}", "${var.virtual_machine_map.name.identifier}", "${var.virtual_machine_index}")
    vm_region_map = tomap({
        for k, v in var.resources.azure_locations.vm_regions : k => v
    })

    region_map = tomap({
        for k, v in var.resources.azure_locations.regions : k => v
    })
}