#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

# As part of this repository I have decided to implement automatic region naming convention as part of the resource.

locals {
    region_map = tomap({
        for k, v in var.resources.azure_locations.regions : k => v
    })
}
