#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

###########################
# PUBLIC IP PREFIX MODULE #
###########################

module "public_ip_prefix" {
depends_on              = []
    source              = "../../network/azurerm_public_ip_prefix"
    count               = var.virtual_machine_map.attach_public_ip == true ? 1 : 0
    resources           = var.resources
    main                = var.main
    environment         = var.environment
    dateCreated         = var.dateCreated
    managedBy           = var.managedBy
    location            = var.virtual_machine_map.resource_group.location
    resource_group      = format("%s-%s-%s-%s-%s", "${var.resources.resource_types.rgResourceType}", "${var.virtual_machine_map.resource_group.purpose}", "${var.environment}", "${local.region_map[coalesce(var.virtual_machine_map.resource_group.location)]}", "${var.virtual_machine_map.resource_group.identifier}")
    resource_name       = local.virtual_machine_scale_set_name
}

###################################
# LINUX VIRTUAL MACHINE SCALE SET #
###################################

resource "azurerm_linux_virtual_machine_scale_set" "linux_scale_set" {
depends_on = [module.public_ip_prefix]
    name = "${local.virtual_machine_scale_set_name}"
    resource_group_name = data.azurerm_resource_group.resource_group[0].name
    location = var.virtual_machine_map.resource_group.location
    sku = var.virtual_machine_map.settings.size
    encryption_at_host_enabled = false
    instances = var.virtual_machine_map.settings.instances
    disable_password_authentication = lookup(var.virtual_machine_map, "use_ssh_authentication", false) != false ? true : false
    admin_username = var.virtual_machine_map.settings.username
    admin_password = null
    zone_balance = true
    zones = ["1", "2", "3"]
    custom_data = var.virtual_machine_map.cloudinit.enable == true ? base64encode(data.cloudinit_config.functions.rendered) : null
    tags = merge(tomap({ 
        Environment = "${title(var.environment)}",
        ManagedBy = "${title(var.managedBy)}",
        DateCreated = "${var.dateCreated}",
        Role = "${title(var.virtual_machine_map.tags.role)}",
        Owner = "${title(var.virtual_machine_map.tags.owner)}",
        ResourceType = "Virtual Machine Scale Set",
        osType = "${var.os_settings.osType}"  }), var.tags,)

    dynamic "admin_ssh_key" {
        for_each = lookup(var.virtual_machine_map, "use_ssh_authentication", false) != false ? [1] : []
        content {
            username = try(lookup(var.virtual_machine_map.settings, "username", "adminuser"), null)
            public_key = var.ssh_public_key # <-- This can be pulled in from hashicorp vault or key vault.
        }
    }

    source_image_reference {
        publisher = var.os_settings.publisher
        offer = var.os_settings.offer
        sku = var.os_settings.sku
        version = var.os_settings.version
    }

    os_disk {
        storage_account_type = "Standard_LRS"
        caching              = "ReadWrite"
    }

    network_interface {
        name    = format("%s-%s", "${var.resources.resource_types.nicResourceType}", "${local.virtual_machine_scale_set_name}")
        primary = true

        ip_configuration {
        name      = format("%s-%s", "${var.resources.resource_types.ipResourceType}", "${local.virtual_machine_scale_set_name}")
        primary   = true
        subnet_id = data.azurerm_subnet.subnet.id
        
        dynamic "public_ip_address" {
            for_each = range(var.virtual_machine_map.attach_public_ip == true ? 1 : 0)
                content {
                    name = format("%s-%s", "${var.resources.resource_types.pipResourceType}", "${local.virtual_machine_scale_set_name}")
                    public_ip_prefix_id = module.public_ip_prefix[0].public_ip_prefix_id
                }
            }
        }
    }
    lifecycle {
        ignore_changes = [admin_password, tags]
    }
}

##############
# CLOUD INIT #
##############

data "cloudinit_config" "functions" {
depends_on = []
    gzip = false
    base64_encode = false

    dynamic "part" {
        for_each = range(var.virtual_machine_map.cloudinit.web_server.enable_ngnix == true ? 1 : 0)
        content {
        content = templatefile("${path.module}/scripts/run-nginx-install.yaml",
        {
            install_agent_script_b64 = filebase64("${path.module}/scripts/install_nginx.sh")
            user = var.virtual_machine_map.settings.username
        })
        content_type = "text/cloud-config"
        merge_type = "list(append)+dict(recurse_array)+str()"
        }
    }
}

