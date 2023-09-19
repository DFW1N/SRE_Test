#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

#############
# PUBLIC IP #
#############

resource "azurerm_public_ip" "public_ip" {
depends_on = []
    name = format("%s-%s", "${var.resources.resource_types.pipResourceType}", "${try(var.resource_name, var.resource_group)}")
    resource_group_name = format("%s", "${var.resource_group}")
    location = var.location
    allocation_method = "Static"
    tags = merge(tomap({ 
        Environment = "${title(var.environment)}", 
        ManagedBy = "${title(var.managedBy)}", 
        DateCreated = "${var.dateCreated}", 
        ResourceType = "Public IP Address",
        AssignedTo = "${var.resource_name}"  }), var.tags,)
    lifecycle {
        ignore_changes = [tags]
    }
}
