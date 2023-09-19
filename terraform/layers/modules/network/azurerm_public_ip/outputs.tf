#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

# I have created the outputs file additional as it can be used for inspec testing or pulling this value into other modules using outputs instead.

output "public_ip_ids" {
    value = try(module.public_ips.public_ip_ids, null)
}

output "public_ip_addresses" {
    value = try(module.public_ips.public_ip_addresses, null)
}
