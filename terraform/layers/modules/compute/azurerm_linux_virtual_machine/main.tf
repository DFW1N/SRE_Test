#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

module "linux_virtual_machine" {
depends_on                  = []
    source                  = "../../../main/compute/azurerm_linux_virtual_machine"
    count                   = 1
    resources               = var.resources
    main                    = var.main
    os_settings             = var.resources.virtual_machines.ubuntu
    virtual_machine_map     = var.main.virtual_machines.virtual_machine_1
    virtual_machine_index   = "${format("%01s", count.index + 1)}"
    environment             = var.environment
    dateCreated             = var.dateCreated
    managedBy               = var.managedBy
}