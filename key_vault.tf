### Requirements:

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.54.0" # Tested on this provider version, but will allow future patch versions.
    }
  }
  required_version = "~> 1.14.0" # Tested on this Terraform CLI version, but will allow future patch versions.
}

### Data:

### Resources:

resource "azurerm_key_vault" "this" {
  for_each = local.key_vaults

  ### Basic

  location            = each.value.location
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  sku_name            = each.value.sku_name
  tags                = each.value.tags
  tenant_id           = coalesce(each.value.tenant_id, var.configuration.tenant_id) # If tenant_id is not present, use tenant_id from the client.

  ### Access

  enabled_for_deployment          = each.value.enabled_for_deployment
  enabled_for_disk_encryption     = each.value.enabled_for_disk_encryption
  enabled_for_template_deployment = each.value.enabled_for_template_deployment
  rbac_authorization_enabled      = each.value.rbac_authorization_enabled

  ### Network

  dynamic "network_acls" {
    for_each = each.value.network_acls
    content {
      default_action             = network_acls.value.default_action
      bypass                     = network_acls.value.bypass
      virtual_network_subnet_ids = network_acls.value.virtual_network_subnet_ids
      ip_rules                   = network_acls.value.ip_rules
    }
  }

  ### Retention

  purge_protection_enabled   = each.value.purge_protection_enabled
  soft_delete_retention_days = each.value.soft_delete_retention_days
}

###### Sub-resource & Additional Modules

module "lupus_az_monitor_diagnostic_setting" {
  depends_on = [azurerm_key_vault.this] # Ensures resource group exists before role assignments are created.
  source  = "lupusllc/monitor-diagnostic-setting/azurerm" # https://registry.terraform.io/modules/lupusllc/monitor-diagnostic-setting/azurerm/latest
  version = "0.0.1"

  ### Basic

  configuration               = var.configuration
  monitor_diagnostic_settings = local.monitor_diagnostic_settings
}

module "lupus_az_role_assignment" {
  depends_on = [azurerm_key_vault.this] # Ensures resource group exists before role assignments are created.
  source  = "lupusllc/role-assignment/azurerm" # https://registry.terraform.io/modules/lupusllc/storage-account/azurerm/latest
  version = "0.0.3"

  ### Basic

  role_assignments = local.role_assignments
}
