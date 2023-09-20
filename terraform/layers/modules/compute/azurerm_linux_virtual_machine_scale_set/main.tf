#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#


module "linux_virtual_machine_scale_set" {
depends_on                  = []
    count                   = 1
    source                  = "../../../main/compute/azurerm_linux_virtual_machine_scale_set"
    resources               = var.resources
    main                    = var.main
    os_settings             = var.resources.virtual_machines.ubuntu
    resource_group          = var.main.resource_groups.azure_devops_agents
    virtual_machine_map     = var.main.linux_virtual_machine_scale_sets.linux_scale_set_1
    subnet                  = var.main.subnets.subnet_1
    virtual_machine_index   = "${format("%01s", count.index + 1)}"
    environment             = var.environment
    dateCreated             = var.dateCreated
    managedBy               = var.managedBy
}