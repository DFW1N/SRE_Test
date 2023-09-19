#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

###################
# RESOURCE GROUPS #
###################

resource "azurerm_resource_group" "resource_groups" {
for_each = "${var.resource_groups}"
    name = format("%s-%s-%s-%s-%s", "${var.resources.resource_types.rgResourceType}", "${each.value.purpose}", "${var.environment}", "${local.region_map[coalesce(each.value.location)]}", "${each.value.identifier}")
    location = "${each.value.location}"
    tags = merge(tomap({ 
        Environment = "${title(var.environment)}", 
        Role = "${each.value.tags.role}",  
        ManagedBy = "${title(var.managedBy)}", 
        Owner = "${each.value.tags.owner}", 
        ProjectName = "${upper(var.resources.global_prefixes.general.projectName)}", 
        ResourceType = "Resource Group", 
        CostCentre = "${upper(var.resources.global_prefixes.general.costCentre)}"  }), var.tags,)
    lifecycle {
        ignore_changes = [tags]
    }
}
