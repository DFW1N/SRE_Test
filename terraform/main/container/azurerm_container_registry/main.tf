#============================================================================#
#                                                                            #
#                       Date Created: 21/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#

############################
# Azure Container Registry #
############################

resource "azurerm_container_registry" "acr" {
  depends_on                    = [module.user_assigned_identity]
  for_each                      = var.container_registries
  name                          = format("%s%s%s%s%s", "${var.resources.resource_types.acrResourceType}", "${each.value.name.purpose}", "${var.environment}", "${local.region_map[coalesce(each.value.resource_group.location)]}", "${each.value.name.identifier}")
  resource_group_name           = format("%s-%s-%s-%s-%s", "${var.resources.resource_types.rgResourceType}", "${each.value.resource_group.purpose}", "${var.environment}", "${local.region_map[coalesce(each.value.resource_group.location)]}", "${each.value.resource_group.identifier}")
  location                      = try(each.value.resource_group.location, var.location)
  sku                           = title(each.value.settings.sku)
  admin_enabled                 = try(each.value.settings.admin_enabled, false)
  public_network_access_enabled = try(each.value.settings.public_network_access_enabled, false)
  quarantine_policy_enabled     = try(each.value.settings.quarantine_policy_enabled, false)
  export_policy_enabled         = each.value.settings.public_network_access_enabled == false ? try(each.value.settings.export_policy_enabled, false) : true
  zone_redundancy_enabled       = try(each.value.settings.zone_redundancy_enabled, false)
  anonymous_pull_enabled        = try(each.value.settings.anonymous_pull_enabled, false)
  data_endpoint_enabled         = each.value.settings.sku == title("Premium") ? try(each.value.settings.data_endpoint_enabled, false) : false
  network_rule_bypass_option    = try(each.value.settings.network_rule_bypass_option, "AzureServices")
  tags = merge(tomap({
    Environment  = "${title(var.environment)}",
    ManagedBy    = "${title(var.managedBy)}",
    DateCreated  = "${var.dateCreated}",
    Role         = "${title(each.value.tags.role)}",
    Owner        = "${title(each.value.tags.owner)}",
    ResourceType = "Azure Container Registry" }), var.tags, )

  lifecycle {
    ignore_changes = [tags]
  }
}