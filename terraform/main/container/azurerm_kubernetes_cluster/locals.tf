#============================================================================#
#                                                                            #
#                       Date Created: 21/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

locals {
  region_map = tomap({
    for k, v in var.resources.azure_locations.regions : k => v
  })
}