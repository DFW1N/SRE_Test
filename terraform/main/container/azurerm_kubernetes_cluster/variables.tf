#============================================================================#
#                                                                            #
#                       Date Created: 21/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

variable "kubernetes_cluster" {
  description = "The resource map that will be used for the module"
  type        = any
  default     = null
}

variable "resources" {
  description = "The resource inside the resources tfvars file map"
  type        = any
  default     = null
}

variable "main" {
  description = "The main resource map inside the main tfvars file map"
  type        = any
  default     = null
}

variable "location" {
  description = "The default location string if nothing is declared."
  type        = string
  default     = null
}

variable "environment" {
  description = "The environment prefix assoicated to the resource"
  type        = string
  default     = null
}

variable "managedBy" {
  description = "What is the resource that is managing the resource group"
  type        = string
  default     = null
}

variable "dateCreated" {
  description = "The date that the resource was deployed."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of the tags to use for the resources that are deployed"
  type        = map(string)
  default     = {}
}

variable "ssh_public_key" {
  description = "The ssh public key value that will be deployed ontop the scale set."
  type = string
  default = null
  sensitive = true
}
