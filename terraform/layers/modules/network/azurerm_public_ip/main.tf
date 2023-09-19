#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

#####################################################################################
## NOTICE: Any module without a /config directory is being used as a child module. ##
#####################################################################################
  
##################################################################################
# NOTICE: Currently in use at main/compute/azurerm_linux_virtual_machine/main.tf #
##################################################################################

####################
# PUBLIC IP MODULE #
####################

module "public_ips {
depends_on             = []
  source               = "../../../main/network/azurerm_public_ip" # <--- I am using relative directory structure in this example but this can be replaced with other solutions.
  resources            = var.resources
  main                 = var.main
}
