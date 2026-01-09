# Helps to combine data, easier debug and remove complexity in the main resource.

locals {
  key_vaults_list = [
    for index, key_vault in var.key_vaults : {
      # Most will try and use key/value key_vault first, then try applicable defaults and then null as a last resort.

      ### Basic

      index               = index # Added in case it's ever needed, since for_each/for loops don't have inherent indexes.
      location            = try(coalesce(key_vault.location, try(var.defaults.location, null)), null)
      name                = key_vault.name
      resource_group_name = try(coalesce(key_vault.resource_group_name, try(var.defaults.resource_group_name, null)), null)
      sku_name            = key_vault.sku_name
      # Merges key_vault or default tags with required tags.
      tags = merge(
        # Count key_vault tags, if greater than 0 use them, otherwise try defaults tags if they exist, if not use a blank map. 
        length(key_vault.tags) > 0 ? key_vault.tags : try(var.defaults.tags, {}),
        try(var.required.tags, {})
      )
      tenant_id = key_vault.tenant_id

      ### Access

      enabled_for_deployment          = key_vault.enabled_for_deployment
      enabled_for_disk_encryption     = key_vault.enabled_for_disk_encryption
      enabled_for_template_deployment = key_vault.enabled_for_template_deployment
      public_network_access_enabled   = key_vault.public_network_access_enabled
      rbac_authorization_enabled      = key_vault.rbac_authorization_enabled

      ### Network

      # This object is going to be encased in a list for dynamic block requirements, despite always being a single item.
      # The input variable is not required to be in a list for a better user experience since it's not needed or logical.
      #
      # If object is null, provide an empty list. Otherwise, make a list of the object with the following changes.
      # In this case, we're listing out all variables so we can filter out ones not used by the resource, just in case.

      network_acls = key_vault.network_acls == null ? [] : [{

        bypass         = key_vault.network_acls.bypass
        default_action = key_vault.network_acls.default_action
        ip_rules       = key_vault.network_acls.ip_rules

        # Iterate through virtual_network_subnets to build out subnet IDs.
        virtual_network_subnet_ids = [for subnet in key_vault.network_acls.virtual_network_subnets :
          # If virtual_network_subnet_id is provided, use it directly.
          subnet.virtual_network_subnet_id != null ? subnet.virtual_network_subnet_id : (
            # Otherwise, if virtual network ID and subnet name are provided, construct the subnet ID.
            subnet.virtual_network_id != null && subnet.virtual_network_subnet_name != null ? format(
              "%s/subnets/%s",
              subnet.virtual_network_id,
              subnet.virtual_network_subnet_name
            ) :
            # Otherwise, construct the subnet ID from the subscription, virtual network name, resource group name, subnet name.
            format(
              "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/virtualNetworks/%s/subnets/%s",
              var.configuration.subscription_id,
              subnet.virtual_network_resource_group_name,
              subnet.virtual_network_name,
              subnet.virtual_network_subnet_name
            )
          )
        ]
      }]

      ### Retention

      purge_protection_enabled   = key_vault.purge_protection_enabled
      soft_delete_retention_days = key_vault.soft_delete_retention_days

      ###### Sub-resource & Additional Modules

      monitor_diagnostic_settings = key_vault.monitor_diagnostic_settings
      role_assignments            = key_vault.role_assignments
    }
  ]

  # Used to create unique id for for_each loops, as just using the name may not be unique.
  key_vaults = {
    for key_vault in local.key_vaults_list : "${key_vault.resource_group_name}>${key_vault.name}" => key_vault
  }

  ### Sub-resource & Additional Modules

  # Iterate local.key_vaults_list and monitor_diagnostic_settings to build a flat list of monitor_diagnostic_settings with key_vault_name & key_vault_resource_group_name.
  monitor_diagnostic_settings = flatten([
    for key_vault in local.key_vaults_list : [
      for monitor_diagnostic_setting in key_vault.monitor_diagnostic_settings : {
        # Check length of enabled_log and enabled_metric, if they don't exist set to zero. If both are zero, use a base default for the resource.
        enabled_log = try(length(monitor_diagnostic_setting.enabled_log), 0) == 0 && try(length(monitor_diagnostic_setting.enabled_metric), 0) == 0 ? [{
          # Options as of 1/7/2025 per data export of azurerm_monitor_diagnostic_categories.
          # Category (Type): AuditEvent, AzurePolicyEvaluationDetails
          # Category Group: allLogs, audit
          category_group = "allLogs"
          # Otherwise, try and use what was provided. If nothing, a blank list.
        }] : try(monitor_diagnostic_setting.enabled_log, [])
        # Check length of enabled_log and enabled_metric, if they don't exist set to zero. If both are zero, use a base default for the resource.
        enabled_metric = try(length(monitor_diagnostic_setting.enabled_log), 0) == 0 && try(length(monitor_diagnostic_setting.enabled_metric), 0) == 0 ? [{
          # Options as of 1/7/2025 per data export of azurerm_monitor_diagnostic_categories.
          # Category: AllMetrics
          category = "AllMetrics"
          # Otherwise, try and use what was provided. If nothing, a blank list.
        }] : try(monitor_diagnostic_setting.enabled_metric, [])
        log_analytics_workspace_id = format(
          "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.OperationalInsights/workspaces/%s",
          var.configuration.subscription_id,
          monitor_diagnostic_setting.log_analytics_workspace_resource_group_name,
          monitor_diagnostic_setting.log_analytics_workspace_name
        )
        name                       = try(monitor_diagnostic_setting.name, null)
        target_name                = key_vault.name
        target_resource_group_name = key_vault.resource_group_name
        target_resource_id = format(
          "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.KeyVault/vaults/%s",
          var.configuration.subscription_id,
          key_vault.resource_group_name,
          key_vault.name
        )
      }
    ] if length(key_vault.monitor_diagnostic_settings) > 0 # Filters out any empty storage container lists.
  ])

  # Iterate local.key_vaults_list and role_assignments to build a flat list of role_assignments with proper scope and unique IDs.
  role_assignments = flatten([
    for key_vault in local.key_vaults_list : [
      for role_assignment in key_vault.role_assignments : merge(role_assignment, {
        scope = azurerm_key_vault.this["${key_vault.resource_group_name}>${key_vault.name}"].id
        unique_for_each_id = format(
          "%s>%s>%s>%s",
          key_vault.resource_group_name,
          key_vault.name,
          role_assignment.principal_id,
          coalesce(try(role_assignment.role_definition_name, null), try(role_assignment.role_definition_id, null))
        )
      })
    ] if length(key_vault.role_assignments) > 0 # Filters out any empty role assignment lists.
  ])
}
