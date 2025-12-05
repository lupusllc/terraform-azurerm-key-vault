# Helps to combine data, easier debug and remove complexity in the main resource.

locals {
  key_vaults_list = [
    for index, settings in var.key_vaults : {
      # Most will try and use key/value settings first, then try applicable defaults and then null as a last resort.

      ### Basic

      index               = index # Added in case it's ever needed, since for_each/for loops don't have inherent indexes.
      location            = try(coalesce(settings.location, try(var.defaults.location, null)), null)
      name                = settings.name
      resource_group_name = try(coalesce(settings.resource_group_name, try(var.defaults.resource_group_name, null)), null)
      sku_name            = settings.sku_name
      # Merges settings or default tags with required tags.
      tags = merge(
        # Count settings tags, if greater than 0 use them, otherwise try defaults tags if they exist, if not use a blank map. 
        length(settings.tags) > 0 ? settings.tags : try(var.defaults.tags, {}),
        try(var.required.tags, {})
      )
      tenant_id = settings.tenant_id

      ### Access

      enabled_for_deployment          = settings.enabled_for_deployment
      enabled_for_disk_encryption     = settings.enabled_for_disk_encryption
      enabled_for_template_deployment = settings.enabled_for_template_deployment
      rbac_authorization_enabled      = settings.rbac_authorization_enabled

      ### Network

      # Iterate through network_acls.
      network_acls = [for index, acl in settings.network_acls : {
        bypass         = acl.bypass
        default_action = acl.default_action
        ip_rules       = acl.ip_rules

        # Iterate through virtual_network_subnets to build out subnet IDs.
        virtual_network_subnet_ids = [for item in acl.virtual_network_subnets :
          # If virtual_network_subnet_id is provided, use it directly.
          item.virtual_network_subnet_id != null ? item.virtual_network_subnet_id : (
            # Otherwise, if virtual network ID and subnet name are provided, construct the subnet ID.
            item.virtual_network_id != null && item.virtual_network_subnet_name != null ? format(
              "%s/subnets/%s",
              item.virtual_network_id,
              item.virtual_network_subnet_name
            ) :
            # Otherwise, construct the subnet ID from the subscription, virtual network name, resource group name, subnet name.
            format(
              "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Network/virtualNetworks/%s/subnets/%s",
              data.azurerm_client_config.current.subscription_id,
              item.virtual_network_resource_group_name,
              item.virtual_network_name,
            item.virtual_network_subnet_name)
          )
        ]
      }]

      ### Retention

      purge_protection_enabled   = settings.purge_protection_enabled
      soft_delete_retention_days = settings.soft_delete_retention_days
    }
  ]

  # Used to create unique id for for_each loops, as just using the name may not be unique.
  key_vaults = {
    for index, settings in local.key_vaults_list : "${settings.resource_group_name}>${settings.name}" => settings
  }
}