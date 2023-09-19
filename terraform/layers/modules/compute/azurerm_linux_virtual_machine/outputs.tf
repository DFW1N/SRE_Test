#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

output "linux_virtual_machine_ids" {
    value = try(module.linux_virtual_machine.linux_virtual_machine_ids, null)
}

output "linux_virtual_machine_names" {
    value = try(module.linux_virtual_machine.linux_virtual_machine_names, null)
}

output "virtual_machine_resource_group_names" {
    value = try(module.linux_virtual_machine.virtual_machine_resource_group_names, null)
}
