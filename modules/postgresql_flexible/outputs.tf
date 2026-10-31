output "server_id" {
  description = "The ID of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.this.id
}

output "server_fqdn" {
  description = "Fully qualified domain name of the PostgreSQL Flexible Server"
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "database_ids" {
  description = "Map of database names to their resource IDs"
  value       = { for db, res in azurerm_postgresql_flexible_server_database.this : db => res.id }
}
