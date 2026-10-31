output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.this.name
}

output "vnet_id" {
  description = "The Virtual Network ID"
  value       = module.network.vnet_id
}

output "subnet_ids" {
  description = "Map of provisioned subnet IDs"
  value       = module.network.subnet_ids
}

output "frontend_web_endpoint" {
  description = "Azure Storage Static Website endpoint URL"
  value       = module.frontend_storage.primary_web_endpoint
}

output "backend_vm_private_ips" {
  description = "Private IP of backend Linux VM"
  value       = module.backend_vm.vm_private_ips
}

output "database_fqdn" {
  description = "PostgreSQL Flexible Server private FQDN"
  value       = module.database.server_fqdn
}

output "key_vault_uri" {
  description = "Azure Key Vault URI"
  value       = module.key_vault.key_vault_uri
}
