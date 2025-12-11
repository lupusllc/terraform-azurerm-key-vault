output "key_vaults" {
  description = "The key vaults."
  value       = azurerm_key_vault.this
}

output "key_vault_role_assignments" {
  description = "The key vault role assignments."
  value = merge(
    [
      for name, results in module.lupus_az_role_assignment : results.role_assignments
    ]... # Unpack the list of lists into a single list.
  )
}

### Debug Only

output "var_key_vaults" {
  value = var.key_vaults
}

output "local_key_vaults" {
  value = local.key_vaults
}

output "local_key_vault_role_assignments" {
  value = local.role_assignments
}
