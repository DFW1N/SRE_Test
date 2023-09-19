#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

variable "resources" {
  description = "The resource inside the resources tfvars file map"
  type = any
  default = null
}

variable "main" {
  description = "The main resource inside the resources tfvars file map"
  type = any
  default = null
}

variable "environment" {
  description = "The environment prefix assoicated to the resource"
  type = string
  default = null
}

variable "managedBy" {
  description = "What is the resource that is managing the resource group"
  type = string
  default = null
}

variable "dateCreated" {
  description = "The date that the resource was deployed."
  type = string
  default = null
}

variable "resource_group" {
  description = "The resource group thats being imported"
  type = any
  default = null
}

variable "resource_name" {
  description = "The resource name thats being imported"
  type = any
  default = null
}

variable "resource_map" {
  description = "The resource map thats being imported"
  type = any
  default = null
}

variable "subnet" {
  description = "The resource subnet thats being imported"
  type = any
  default = null
}

variable "tags" {
  description = "A map of the tags to use for the resources that are deployed"
  type = map(string)
  default = {}
}