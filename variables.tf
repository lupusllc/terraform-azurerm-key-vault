### Defaults

variable "defaults" {
  default     = {} # Defaults to an empty map.
  description = "Defaults used for resources when nothing is specified for the resource."
  nullable    = false # This will treat null values as unset, which will allow for use of defaults.
  type        = any
}

### Required

variable "required" {
  default     = {} # Defaults to an empty map.
  description = "Required resource values, as applicable."
  nullable    = false # This will treat null values as unset, which will allow for use of defaults.
  type        = any
}

### Dependencies

# This data source from root is used because using data calls in child modules can inadvertently cause resource recreation.
variable "configuration" {
  description = "Configuration data such as Tenant ID and Subscription ID."
  nullable    = false
  type = object({
    client_id       = string
    id              = string
    object_id       = string
    subscription_id = string
    tenant_id       = string
  })
}

### Resources

variable "key_vaults" {
  default     = [] # Defaults to an empty list.
  description = "Key Vaults."
  nullable    = false # This will treat null values as unset, which will allow for use of defaults.
  type = list(object({
    ### Basic

    location            = optional(string, null) # Defaults to null, which attempts to use defaults.
    name                = string
    resource_group_name = optional(string, null)       # Defaults to null, which attempts to use defaults.
    sku_name            = optional(string, "standard") # standard, premium. Defaults to standard.
    tags                = optional(map(string), {})
    tenant_id           = optional(string, null) # Defaults to null which uses connection tenant ID if not provided.

    ### Access

    # The access_policy object is not provided as we should be using RBAC authorization and it's best to use azurerm_key_vault_access_policy even if you are.
    enabled_for_deployment          = optional(bool, null) # Defaults to null for resource default of false.
    enabled_for_disk_encryption     = optional(bool, null) # Defaults to null for resource default of false.
    enabled_for_template_deployment = optional(bool, null) # Defaults to null for resource default of false.
    public_network_access_enabled   = optional(bool, null) # Defaults to null for resource default of true.
    rbac_authorization_enabled      = optional(bool, true) # Defaults to true.

    ### Network

    network_acls = optional(object({
      bypass         = optional(string, "AzureServices") # AzureService, None. Defaults to AzureServices.
      default_action = optional(string, "Allow")         # Allow, Deny. Defaults to Allow.
      ip_rules       = optional(list(string), [])
      virtual_network_subnets = optional(list(object({
        virtual_network_id                  = optional(string, null) # Second priority, if provided will be used with the subnet name.
        virtual_network_name                = optional(string, null) # Ignored if virtual_network_id or virtual_network_subnet_name is provided.
        virtual_network_resource_group_name = optional(string, null) # Ignored if virtual_network_id or virtual_network_subnet_name is provided.
        virtual_network_subnet_id           = optional(string, null) # First priority, if provided will be used.
        virtual_network_subnet_name         = optional(string, null) # Ignored if virtual_network_subnet_id is provided.
      })), [])
    }), null) # We can't use blank object or it will inject unwanted data, so null is used instead.

    ### Retention

    purge_protection_enabled   = optional(bool, true)
    soft_delete_retention_days = optional(number, 30)

    ###### Sub-resource & Additional Modules
    # Since parent is known, these can be created here, which makes it easier for users.
    # We don't specify the type here because the module itself will validate the structure. See the module variables for details for configuration.
    #
    # WARNING: Moving these resources to it's direct module will require recreation or state file manipulation.

    monitor_diagnostic_settings = optional(any, []) # This is only for basic log analytics integration, at this time.
    role_assignments            = optional(any, [])
  }))
}
