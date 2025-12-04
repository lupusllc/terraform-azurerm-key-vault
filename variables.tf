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

    ### Retention

    purge_protection_enabled   = optional(bool, true)
    soft_delete_retention_days = optional(number, 30)
  }))
}
