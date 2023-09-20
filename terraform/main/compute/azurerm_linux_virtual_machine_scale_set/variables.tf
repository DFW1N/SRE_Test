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
  description = "The main resource map inside the main tfvars file map"
  type = any
  default = null
}

variable "resource_group" {
  description = "The resource group map that will be used for the virtual machine module"
  type = any
  default = null
}

variable "virtual_machine_map" {
  description = "The virtual machine map that will be used for the virtual machine module"
  type = any
  default = null
}

variable "key_vault_map" {
  description = "The key vault map that will be used for the virtual machine module"
  type = any
  default = null
}

variable "virtual_machine_index" {
  description = "The virtual machine index that will be used for the virtual machine module"
  type = any
  default = null
}

variable "os_settings" {
  description = "The virtual machine operating system settings that will be used for the virtual machine module"
  type = any
  default = null
}

variable "subnet" {
  description = "The subnet map that will be used for the virtual machine module"
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

variable "tags" {
  description = "A map of the tags to use for the resources that are deployed"
  type = map(string)
  default = {}
}