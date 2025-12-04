WIP -> Examples and arguments need to be flushed out
  
---
  
This [public repo](https://github.com/lupusllc/terraform-azurerm-key-vault) is the source for this public Terraform module.
  
## Purpose
  
This module was created to expand provider capabilities, implement org standards and defaults. 
  
This helps shift complexity right (module side), while reducing complexity left (root/user side). So configuration is more easily defined at the vars/tfvars level.
  
### Enhanced Capabilities
  
* Uses a list of objects to create zero or more resources.
* Uses a default map for common defaults, when not provided.
  * Location
  * Resource Group
  * Tags
* Uses a required map for required items, that should be on all applicable resources.
  * Tags
* Handles dependencies checking at the module level.
* Root/user level terraform is more simplified.
  
## Provider
  
This module uses the azurerm provider.
  
## Arguments: Root Level
  
Arguments | Required | Type | Default | Example | Description
--------- | -------- | ---- | ------- | ------- | -----------
defaults | no | map() | {} | [Example](#arguments-defaults-example) | Default items to use for resources for this and sub-modules if those aren't provided.
key-vaults | no | list(object()) | [] | [Example](#arguments-key-vaults-example) | A list of objects, used to create zero or more resource groups.
required | no | map() | {} | [Example](#arguments-required-example) | Required items to use for resources for this and sub-modules, as applicable.
  
## Arguments: defaults
  
The defaults map uses the following for resources created, if those settings aren't provided.
  
Arguments | Required | Type | Default | Example | Description
--------- | -------- | ---- | ------- | ------- | -----------
location | no | string | | [Example](#arguments-defaults-example) | Resource location.
tags | no | map(string) | | [Example](#arguments-defaults-example) | Resource tags.
  
### Arguments: defaults: Example
  
```
{
  location = "eastus"
  tags = { default_tag = "default level" }
}
```
  
## Arguments: key-vaults
  
The key-vaults list of objects defines the resource groups to be created.
  
Arguments | Required | Type | Default | Example | Description
--------- | -------- | ---- | ------- | ------- | -----------
location | yes* | string | | [Example](#arguments-key-vaults-example) | Resource location.
name | yes | string | | [Example](#arguments-key-vaults-example) | Resource name.
tags | no | map(string) | | [Example](#arguments-key-vaults-example) | Resource tags, these tags will be combined with required tags if provided.
  
\* These are only required if defaults do not provide these values.
  
### Arguments: key-vaults: Example
  
```
[
  {
    name = "example-min-wus-rg"
    location = "westus"
    tags = { resource_tag = "resource level" }
  }
]
```
  
## Arguments: required
  
The required map uses the following for all applicable resources created.
  
Arguments | Required | Type | Default | Example | Description
--------- | -------- | ---- | ------- | ------- | -----------
tags | no | map(string) | | [Example](#arguments-required-example) | Resource tags.
  
### Arguments: required: Example
  
```
{
  tags = { required_tag = "required level" }
}
```
