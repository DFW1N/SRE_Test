#============================================================================#
#                                                                            #
#                       Date Created: 20/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

output "public_ip_prefix" {
    value = try(module.linux_virtual_machine_scale_set.public_ip_prefix, null)
}

output "linux_scale_set_resource_group_name" {
    value = try(module.linux_virtual_machine_scale_set.linux_scale_set_resource_group_name, null)
}