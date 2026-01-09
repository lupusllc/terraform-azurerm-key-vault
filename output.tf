output "key_vaults" {
  description = "The key vaults."
  value       = azurerm_key_vault.this
}

output "key_vault_monitor_diagnostic_settings" {
  description = "The key vault monitor diagnostic settings."
  value       = module.lupus_az_monitor_diagnostic_setting.monitor_diagnostic_settings
}

output "key_vault_role_assignments" {
  description = "The key vault role assignments."
  value       = module.lupus_az_role_assignment.role_assignments
}

### Debug Only

output "var_key_vaults" {
  value = var.key_vaults
}

output "local_key_vaults" {
  value = local.key_vaults
}

output "local_key_vault_monitor_diagnostic_settings" {
  value = local.monitor_diagnostic_settings
}

output "local_key_vault_role_assignments" {
  value = local.role_assignments
}
