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