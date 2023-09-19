#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#


###########################
# NETWORK SECURITY GROUPS #
###########################

resource "null_resource" "previous" {}

resource "time_sleep" "wait_30_seconds" {
    depends_on = [null_resource.previous]
    create_duration = "30s"
}

resource "azurerm_network_security_group" "network_security_groups" {
depends_on = [time_sleep.wait_30_seconds, data.azurerm_subnet.subnets]
    for_each = { for k, v in var.subnets : k => v if lookup(v, "network_security_group", {}) != {} }
    name = format("%s-%v", "${var.resources.resource_types.nsgResourceType}", "${data.azurerm_subnet.subnets[each.key].name}")
    resource_group_name = format("%v", "${data.azurerm_subnet.subnets[each.key].resource_group_name}")
    location = try(each.value.resource_group.location, var.location)
    dynamic "security_rule" {
    for_each = concat(lookup(each.value.network_security_group, "nsg_inbound_rules", []), lookup(each.value.network_security_group, "nsg_outbound_rules", []))
        content {
            name = security_rule.value[0] == "" ? "Default_Rule" : security_rule.value[0]
            priority = security_rule.value[1]
            direction = security_rule.value[2] == "" ? "Inbound" : security_rule.value[2]
            access = security_rule.value[3] == "" ? "Allow" : security_rule.value[3]
            protocol = security_rule.value[4] == "" ? "Tcp" : security_rule.value[4]
            source_port_range = "*"
            destination_port_range = security_rule.value[5] == "" ? "*" : security_rule.value[5]
            source_address_prefix = security_rule.value[6] == "" ? element(each.value.address_prefix, 0) : security_rule.value[6]
            destination_address_prefix = security_rule.value[7] == "" ? element(each.value.address_prefix, 0) : security_rule.value[7]
            description = "${security_rule.value[2]}_Port_${security_rule.value[5]}"
        }
    }
    tags = merge(tomap({ 
        Environment = "${title(var.environment)}", 
        ManagedBy = "${title(var.managedBy)}",
        DateCreated = "${var.dateCreated}", 
        ResourceType = "Network Security Group"  }), var.tags,)
    lifecycle {
        ignore_changes = [tags]
    }
}

#######################################
# NETWORK SECURITY GROUP ASSOCIATIONS #
#######################################

resource "azurerm_subnet_network_security_group_association" "network_security_groups_association" {
depends_on = [time_sleep.wait_30_seconds, azurerm_network_security_group.network_security_groups, data.azurerm_subnet.subnets]
    for_each = { for k, v in var.subnets : k => v if lookup(v, "network_security_group", {}) != {} }
    subnet_id = data.azurerm_subnet.subnets[each.key].id
    network_security_group_id = azurerm_network_security_group.network_security_groups[each.key].id
}