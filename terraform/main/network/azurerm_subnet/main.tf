#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

###########
# SUBNETS #
###########

resource "null_resource" "previous" {}

resource "time_sleep" "wait_30_seconds" {
    depends_on = [null_resource.previous]
    create_duration = "30s"
}

resource "azurerm_subnet" "subnets" {
depends_on = [time_sleep.wait_30_seconds]
    for_each = var.subnets
    name = format("%s-%s-%s-%s-%s", "${var.resources.resource_types.sntResourceType}", "${each.value.name.purpose}", "${var.environment}", "${local.region_map[coalesce(each.value.virtual_network.location)]}", "${each.value.name.identifier}")
    resource_group_name = format("%s-%s-%s-%s-%s", "${var.resources.resource_types.rgResourceType}", "${each.value.resource_group.purpose}", "${var.environment}", "${local.region_map[coalesce(each.value.resource_group.location)]}", "${each.value.resource_group.identifier}")
    virtual_network_name = format("%s-%s-%s-%s-%s", "${var.resources.resource_types.vntResourceType}", "${each.value.virtual_network.purpose}", "${var.environment}", "${local.region_map[coalesce(each.value.virtual_network.location)]}", "${each.value.virtual_network.identifier}")
    address_prefixes = each.value.address_prefix
    private_endpoint_network_policies_enabled = try(each.value.private_link_service_network_policies_enabled, true)
    private_link_service_network_policies_enabled = try(each.value.private_link_service_network_policies_enabled, true)
    service_endpoints = try(each.value.service_endpoints, [])
    service_endpoint_policy_ids = try(each.value.service_endpoint_policy_ids, null)
    dynamic "delegation" {
    for_each = try(var.subnets[each.key].delegations, [])
        content {
            name = try(delegation.key, null)
                service_delegation {
                name = try(delegation.value.name, null)
                actions = try(delegation.value.actions, [])
            }
        }
    }
}

###########################
# NETWORK SECURITY GROUPS #
###########################

module "network_security_groups" {
    depends_on          = [azurerm_subnet.subnets]
    source              = "../azurerm_network_security_group"
    resources           = var.resources
    main                = var.main
    subnets             = var.subnets
    special_subnets     = var.special_subnets
    dateCreated         = var.dateCreated
    managedBy           = var.managedBy
    environment         = var.environment
}