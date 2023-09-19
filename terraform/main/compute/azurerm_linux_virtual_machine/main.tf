#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

#########################
# LINUX VIRTUAL MACHINE #
#########################

resource "azurerm_linux_virtual_machine" "linux" {
depends_on = [
    module.network_interface, 
    data.azurerm_resource_group.resource_group,
    ]
    name = "${local.virtual_machine_name}"
    resource_group_name = data.azurerm_resource_group.resource_group[0].name
    location = var.virtual_machine_map.resource_group.location
    computer_name = local.virtual_machine_name
    allow_extension_operations = try(var.virtual_machine_map.settings.allow_extension_operations, false)
    size = var.virtual_machine_map.settings.size
    admin_username = var.virtual_machine_map.settings.username
    admin_password = "UN1IC0RNS@REC00L12345%"
    disable_password_authentication = lookup(var.virtual_machine_map, "use_ssh_authentication", false) != false ? true : false
    proximity_placement_group_id = try(data.azurerm_proximity_placement_group.proximity_placement_group[0].id, null)
    availability_set_id = try(data.azurerm_availability_set.availability_set[0].id, null)
    capacity_reservation_group_id = lookup(var.virtual_machine_map, "availability_set", {}) == {} && var.virtual_machine_map.settings.attach_capacity_reservation_group == true && lookup(var.virtual_machine_map, "proximity_placement_group", {}) == {} ? try(one(module.capacity_reservation_groups[*].capacity_reservation_group_ids), null) : null
    vtpm_enabled = try(var.virtual_machine_map.settings.vtpm_enabled, false)
    patch_mode = try(var.virtual_machine_map.settings.patch_mode, "ImageDefault")
    provision_vm_agent = try(var.virtual_machine_map.settings.provision_vm_agent, false)
    dedicated_host_group_id = lookup(var.virtual_machine_map, "dedicated_host", {}) == {} ? try(data.azurerm_dedicated_host_group.dedicated_host_group[0].id, null) : null
    dedicated_host_id = lookup(var.virtual_machine_map, "dedicated_host_group", {}) == {} ? try(data.azurerm_dedicated_host.dedicated_host[0].id, null) : null
    priority = try(title(var.virtual_machine_map.settings.priority), title("Regular"))
    secure_boot_enabled = try(var.virtual_machine_map.settings.secure_boot_enabled, true)
    network_interface_ids = [module.network_interface.network_interface_ids,]
    tags = merge(tomap({ 
        Environment = "${title(var.environment)}", 
        ManagedBy = "${title(var.managedBy)}", 
        DateCreated = "${var.dateCreated}", 
        Role = "${title(var.virtual_machine_map.tags.role)}",
        Owner = "${title(var.virtual_machine_map.tags.owner)}",
        ResourceType = "Linux Virtual Machine",
        osType = "${var.os_settings.osType}"  }), var.tags,)

    dynamic "admin_ssh_key" {
        for_each = lookup(var.virtual_machine_map, "use_ssh_authentication", false) != false ? [1] : []
        content {
            username = try(lookup(var.virtual_machine_map.settings, "username", "adminuser"), null)
            public_key = try(file("${path.module}"), null)
        }
    }

    source_image_reference {
        publisher = var.os_settings.publisher
        offer = var.os_settings.offer
        sku = var.os_settings.sku
        version = var.os_settings.version
    }

    additional_capabilities {
        ultra_ssd_enabled = try(var.virtual_machine_map.settings.additional_capabilities.ultra_ssd_enabled, false)
    }

    boot_diagnostics {
        storage_account_uri = try(data.azurerm_storage_account.storage_account[0].primary_blob_endpoint, null)
    }

    identity {
        type = "SystemAssigned"
    }

    lifecycle {
        ignore_changes = [tags, admin_password, boot_diagnostics]
    }
}