#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

####################
# FETCH PUBLIC IPS #
####################

data "azurerm_public_ip" "public_ip" {
depends_on = []
    count = var.resource_map.attach_public_ip == true ? 1 : 0
    name = format("%s-%s", "${var.resources.resource_types.pipResourceType}", "${try(var.resource_name, local.resource_group)}")
    resource_group_name = format("%s-%s-%s-%s-%s", "${var.resources.resource_types.rgResourceType}", "${var.resource_group.purpose}", "${var.environment}", "${local.region_map[coalesce(var.resource_group.location)]}", "${var.resource_group.identifier}")
}

####################
# FETCH SUBNET IDS #
####################

data "azurerm_subnet" "subnet" {
depends_on = []
    name = format("%s-%s-%s-%s-%s", "${var.resources.resource_types.sntResourceType}", "${var.subnet.name.purpose}", "${var.environment}", "${local.region_map[coalesce(var.subnet.virtual_network.location)]}", "${var.subnet.name.identifier}")
    virtual_network_name = format("%s-%s-%s-%s-%s", "${var.resources.resource_types.vntResourceType}", "${var.subnet.virtual_network.purpose}", "${var.environment}", "${local.region_map[coalesce(var.subnet.virtual_network.location)]}", "${var.subnet.virtual_network.identifier}")
    resource_group_name  = format("%s-%s-%s-%s-%s", "${var.resources.resource_types.rgResourceType}", "${var.subnet.resource_group.purpose}", "${var.environment}", "${local.region_map[coalesce(var.subnet.virtual_network.location)]}", "${var.subnet.resource_group.identifier}")
}

##########################
# NETWORK INTERFACE CARD #
##########################

resource "azurerm_network_interface" "network_interface" {
depends_on = [data.azurerm_subnet.subnet]
    name = format("%s-%s", "${var.resources.resource_types.nicResourceType}", "${try(var.resource_name, local.resource_group)}")
    location = var.resource_group.location
    resource_group_name = format("%s-%s-%s-%s-%s", "${var.resources.resource_types.rgResourceType}", "${var.resource_group.purpose}", "${var.environment}", "${local.region_map[coalesce(var.resource_group.location)]}", "${var.resource_group.identifier}")
    enable_ip_forwarding = false
    enable_accelerated_networking = false
    tags = merge(tomap({ 
        Environment = "${title(var.environment)}", 
        ManagedBy = "${title(var.managedBy)}", 
        DateCreated = "${var.dateCreated}", 
        ResourceType = "Network Interface Card",
        AssignedTo = "${var.resource_name}"  }), var.tags,)
    ip_configuration {
        name = format("%s-%s", "${var.resources.resource_types.pipResourceType}", "${try(var.resource_name, local.resource_group)}")
        subnet_id = data.azurerm_subnet.subnet.id
        private_ip_address_version = "IPv4"
        private_ip_address_allocation = var.resource_map.ip_addresses == [] ? "Dynamic" : "Static"
        public_ip_address_id = var.resource_map.attach_public_ip == true ? data.azurerm_public_ip.public_ip[0].id : null
    }
    lifecycle {
        ignore_changes = [tags]
    }
}

