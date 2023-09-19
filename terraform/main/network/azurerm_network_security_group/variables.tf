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
  description = "The resources inside the main tfvars file map"
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

variable "subnets_id" {
  description = "The subnet ids."
  type = any
  default = null
}

variable "location" {
  description = "The location the network security group is being deployed to."
  type = string
  default = null
}

variable "resource_names" {
  description = "The resource names."
  type = string
  default = null
}

variable "resource_group_name" {
  description = "The resource group names."
  type = string
  default = null
}

variable "subnets" {
  description = "The for_each map to the subnets thats going to be deployed."
  default = null
}

variable "special_subnets" {
  description = "The for_each map to the special subnets thats going to be deployed."
  default = null
}

variable "tags" {
  description = "A map of the tags to use for the resources that are deployed"
  type = map(string)
  default = {}
}