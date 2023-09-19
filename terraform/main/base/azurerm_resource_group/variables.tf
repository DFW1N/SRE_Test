#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

variable "location" {
  description                 = "The location that the resources are being deployed to in the module"
  type                        = string
  default                     = null
}

variable "resources" {
  description                 = "The resource inside the resources tfvars file map"
  type                        = any
  default                     = null
}

variable "environment" {
  description                 = "The environment prefix assoicated to the resource"
  type                        = string
  default                     = null
}

variable "managedBy" {
  description                 = "What is the resource that is managing the resource group"
  type                        = string
  default                     = null
}

variable "dateCreated" {
  description                 = "The date that the resource was deployed."
  type                        = string
  default                     = null
}

variable "resource_groups" {
  description                 = "The for_each map to the resource groups thats going to be deployed."
  type                        = map(object({
  location                    = string
  purpose                     = string
  identifier                  = string
  enable_lock                 = bool
  tags                        = map(string)
  }))
}

variable "tags" {
  description                 = "A map of the tags to use for the resources that are deployed"
  type                        = map(string)
  default                     = {}
}
