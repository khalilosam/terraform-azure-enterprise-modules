output "storage_account_id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.this.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.this.name
}

output "primary_web_endpoint" {
  description = "The primary web endpoint for the static website"
  value       = try(azurerm_storage_account.this.primary_web_endpoint, null)
}

output "primary_web_host" {
  description = "The primary web host for the static website"
  value       = try(azurerm_storage_account.this.primary_web_host, null)
}

output "primary_blob_endpoint" {
  description = "The primary blob endpoint"
  value       = azurerm_storage_account.this.primary_blob_endpoint
}
