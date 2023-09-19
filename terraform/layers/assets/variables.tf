#============================================================================#
#                                                                            #
# ███████╗██████╗ ███╗   ██╗██╗███████╗                                      #
# ██╔════╝██╔══██╗████╗  ██║██║██╔════╝  # Author: Sacha Roussakis-Notter    #
# ███████╗██████╔╝██╔██╗ ██║██║█████╗    # Lisence: MIT                      #
# ╚════██║██╔══██╗██║╚██╗██║██║██╔══╝    # Date Created: 25/06/2022          #
# ███████║██║  ██║██║ ╚████║██║██║       # Framework: SRNIF                  #
# ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝╚═╝                                           #
# Copyright (c) 2022, Sacha Roussakis-Notter                                 #
#                                                                            #
# ===========================================================================#

##############
# TFVARS MAP #
##############

variable "main" {
  description = "The variables that are mapped under for each platform"
  default = null
}

variable "resources" {
  description = "The variables that are mapped under for resource naming conventions"
  default = null
}

##################################
# AZURE AUTHENTICATION VARIABLES #
##################################

variable "tenant_id" {
  description = "The Tenant Id of the Azure targets these variables are/should be overridden in the Azure DevOps pipelines"
  default = null
  sensitive = true
}

variable "subscription_id" {
  description = "The subscription Id of the Azure targets these variables are/should be overridden in the Azure DevOps pipelines"
  default = null
  sensitive = true
}

variable "subscription_name" {
  description = "The subscription Name of the targets"
  default = null
}

variable "client_secret" {
  description = "The service principal secret these variables are/should be overridden in the Azure DevOps pipelines"
  default = null
  sensitive = true
}

variable "client_id" {
  description = "The service principal client id these variables are/should be overridden in the Azure DevOps pipelines"
  default = null
}
