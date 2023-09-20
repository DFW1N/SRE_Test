#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
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

###########################
# COMMON MODULE VARIABLES #
###########################

variable "dateCreated" {
  description = "The variables that are used and generated at run-time and passed to terraform."
  default = null
}

variable "environment" {
  description = "The environment prefix that is passed to terraform."
  default = null
}

variable "managedBy" {
  description = "The variable that assosicates who is managing this infrastructure stack."
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

variable "ssh_public_key" {
  description = "The ssh public key that will be deployed"
  default = null
  sensitive = true
}
