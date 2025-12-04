output "key_vaults" {
  description = "The key vaults."
  value       = azurerm_key_vault.this
}

### Debug Only

output "var_key_vaults" {
  value = var.key_vaults
}

output "local_key_vaults" {
  value = local.key_vaults
}
