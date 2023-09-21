#============================================================================#
#                                                                            #
#                       Date Created: 21/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

#################
# RANDOM STRING #
#################

resource "random_string" "prefix" {
  length  = 10
  special = false
  upper   = false
  numeric = false
}

resource "azurerm_kubernetes_cluster" "kubernetes_cluster" {
depends_on = [random_string.prefix]
  name                = format("%s-%s-%s-%s-%s", "${var.resources.resource_types.akcResourceType}", "${var.kubernetes_cluster.name.purpose}", "${var.environment}", "${local.region_map[coalesce(var.kubernetes_cluster.resource_group.location)]}", "${var.kubernetes_cluster.name.identifier}")
  location            = try(var.kubernetes_cluster.resource_group.location, var.location)
  resource_group_name = format("%s-%s-%s-%s-%s", "${var.resources.resource_types.rgResourceType}", "${var.kubernetes_cluster.resource_group.purpose}", "${var.environment}", "${local.region_map[coalesce(var.kubernetes_cluster.resource_group.location)]}", "${var.kubernetes_cluster.resource_group.identifier}")
  dns_prefix          = try(var.kubernetes_cluster.settings.dns_prefix, try(var.kubernetes_cluster.settings.dns_prefix_private_cluster, random_string.prefix.result))
  public_network_access_enabled = true
  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
    enable_auto_scaling = true
    max_count = 3
    min_count = 1
  }

  identity {
    type = "SystemAssigned"
  }

  linux_profile {
    admin_username = "adminuser"
    ssh_key {
      key_data = var.ssh_public_key
    }
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }

  tags = merge(tomap({
    Environment  = "${title(var.environment)}",
    ManagedBy    = "${title(var.managedBy)}",
    DateCreated  = "${var.dateCreated}",
    ResourceType = "Kubernetes Cluster" }), var.tags, )
  lifecycle {
    ignore_changes = [
      tags, default_node_pool.0.node_count
    ]
  }
}