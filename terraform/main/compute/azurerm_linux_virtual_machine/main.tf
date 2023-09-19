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
    vtpm_enabled = try(var.virtual_machine_map.settings.vtpm_enabled, false)
    patch_mode = try(var.virtual_machine_map.settings.patch_mode, "ImageDefault")
    provision_vm_agent = try(var.virtual_machine_map.settings.provision_vm_agent, false)
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

    os_disk {
        name = format("%s-%s", "${var.resources.resource_types.dskResourceType}", "${local.virtual_machine_name}")
        caching = try(var.virtual_machine_map.settings.os_disk_settings.caching, var.caching)
        storage_account_type = try(var.virtual_machine_map.settings.os_disk_settings.storage_account_type, var.storage_account_type)
        disk_size_gb = try(var.virtual_machine_map.settings.os_disk_settings.disk_size_gb, var.disk_size_gb)
        write_accelerator_enabled = try(var.virtual_machine_map.settings.os_disk_settings.storage_account_type == "Premium_LRS" || var.storage_account_type == "Premium_LRS" && var.virtual_machine_map.settings.os_disk_settings.caching == "None" || var.caching == "None" ? var.virtual_machine_map.settings.os_disk_settings.write_accelerator_enabled : false, false)
        dynamic "diff_disk_settings" {
            for_each = lookup(var.virtual_machine_map.settings.os_disk_settings, "diff_disk_settings", {}) != {} ? [1] : []
            content {
                option = title("Local")
                placement = try(var.virtual_machine_map.settings.os_disk_settings.diff_disk_settings.placement, var.placement)
            }
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

    identity {
        type = "SystemAssigned"
    }

    lifecycle {
        ignore_changes = [tags, admin_password, boot_diagnostics]
    }
}