#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

####################
# PUBLIC IP PREFIX #
####################

resource "azurerm_public_ip_prefix" "ip_prefix" {
depends_on = []
    name = format("%s-%s", "${var.resources.resource_types.pipResourceType}", "${try(var.resource_name, var.resource_group)}")
    resource_group_name = var.resource_group
    location = var.location
    sku = "Standard"
    prefix_length = 31
    tags = merge(tomap({ 
        Environment = "${title(var.environment)}", 
        ManagedBy = "${title(var.managedBy)}", 
        DateCreated = "${var.dateCreated}", 
        ResourceType = "Public IP Prefix",
        AssignedTo = "${var.resource_name}"  }), var.tags,)
    lifecycle {
        ignore_changes = [tags]
    }
}
