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

# To populate Tenant ID if not provided.
data "azurerm_client_config" "current" {}

### Resources:

resource "azurerm_key_vault" "this" {
  for_each = local.key_vaults

  ### Basic
  location            = each.value.location
  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  sku_name            = each.value.sku_name
  tags                = each.value.tags
  tenant_id           = coalesce(each.value.tenant_id, data.azurerm_client_config.current.tenant_id) # If tenant_id is not present, use tenant_id from the client.

  ### Access
  enabled_for_deployment          = each.value.enabled_for_deployment
  enabled_for_disk_encryption     = each.value.enabled_for_disk_encryption
  enabled_for_template_deployment = each.value.enabled_for_template_deployment
  rbac_authorization_enabled      = each.value.rbac_authorization_enabled

  #network_acls

  ### Retention
  purge_protection_enabled   = each.value.purge_protection_enabled
  soft_delete_retention_days = each.value.soft_delete_retention_days
}
