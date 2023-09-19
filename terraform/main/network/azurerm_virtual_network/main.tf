#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#


####################
# VIRTUAL NETWORKS #
####################

resource "azurerm_virtual_network" "virtual_network" {
  depends_on = [module.data_ddos_protection_plan]
    for_each = var.virtual_networks
    name = format("%s-%s-%s-%s-%s", "${var.resources.resource_types.vntResourceType}", "${each.value.name.purpose}", "${var.environment}", "${local.region_map[coalesce(each.value.name.location)]}", "${each.value.name.identifier}")
    address_space = each.value.address_space
    location = each.value.name.location
    resource_group_name = format("%s-%s-%s-%s-%s", "${var.resources.resource_types.rgResourceType}", "${each.value.resource_group.purpose}", "${var.environment}", "${local.region_map[coalesce(each.value.resource_group.location)]}", "${each.value.resource_group.identifier}")
    dns_servers = each.value.dns_servers
    subnet = []
    tags = merge(tomap({ 
        Environment = "${var.environment}", 
        Role = "${each.value.tags.role}",  
        ManagedBy = "${var.managedBy}", 
        Owner = "${each.value.tags.owner}", 
        DateCreated = "${var.dateCreated}",
        ResourceType = "Virtual Network"  }), var.tags,)
    lifecycle {
        ignore_changes = [tags, subnet]
    }
}