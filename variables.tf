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

# If data source is taken from child module it can inadvertently cause resource recreation.
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

    location            = optional(string)
    name                = string
    resource_group_name = optional(string, null)
    sku_name            = optional(string, "standard")
    tags                = optional(map(string), {})
    tenant_id           = optional(string, null)

    ### Access

    enabled_for_deployment          = optional(bool, false)
    enabled_for_disk_encryption     = optional(bool, false)
    enabled_for_template_deployment = optional(bool, false)
    rbac_authorization_enabled      = optional(bool, true)

    ### Network

    network_acls = optional(list(object({
      bypass         = optional(string, "AzureServices")
      default_action = optional(string, "Allow")
      ip_rules       = optional(list(string), [])
      virtual_network_subnets = optional(list(object({
        virtual_network_id                  = optional(string, null) # Second priority, if provided will be used with the subnet name.
        virtual_network_name                = optional(string, null) # Ignored if virtual_network_id or virtual_network_subnet_name is provided.
        virtual_network_resource_group_name = optional(string, null) # Ignored if virtual_network_id or virtual_network_subnet_name is provided.
        virtual_network_subnet_id           = optional(string, null) # First priority, if provided will be used.
        virtual_network_subnet_name         = optional(string, null) # Ignored if virtual_network_subnet_id is provided.
      })), [])
    })), [])

    ### Retention

    purge_protection_enabled   = optional(bool, true)
    soft_delete_retention_days = optional(number, 30)

    ###### Role Assignments

    # This allows role assignments to be assigned as part of this module, since scope is already known.
    role_assignments = optional(any, [])
  }))
}
