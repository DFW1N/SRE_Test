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

variable "storage_account_type" {
  description = "The os disk storage account type that will be used for the virtual machine module"
  type = string
  default = "Standard_LRS"
  validation {
    condition = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS", "StandardSSD_ZRS", "Premium_ZRS"], var.storage_account_type)
    error_message = "The storage account type for os disk must be Standard_LRS, StandardSSD_LRS, Premium_LRS, StandardSSD_ZRS and Premium_ZRS."
  }
}

variable "disk_size_gb" {
  description = "The os disk size that will be used for the virtual machine module by default if no value is defined in the tfvar config file"
  type = number
  default = 64
}

variable "caching" {
  description = "The os disk caching settings that will be used for the virtual machine module"
  type = string
  default = "ReadWrite"
  validation {
    condition = contains(["ReadOnly", "ReadWrite", "None"], var.caching)
    error_message = "The os disk setting for caching must be ReadOnly, None or ReadWrite."
  }
}

variable "placement" {
  description = "The diff disk caching settings that will be used for the virtual machine module"
  type = string
  default = "CacheDisk"
  validation {
    condition = contains(["ResourceDisk", "CacheDisk"], var.placement)
    error_message = "The os disk setting for caching must be CacheDisk or ResourceDisk."
  }
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
  validation {
    condition = length(var.environment) == 3
    error_message = "Environment variable must be 3 characters long."
  }
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

#################
# RESOURCE MAPS #
#################

variable "virtual_machine_map" {
  description = "The virtual machine map that will be used for the virtual machine module"
  type = any
  default = null
}