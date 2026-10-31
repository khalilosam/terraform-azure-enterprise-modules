output "nsg_id" {
  description = "The ID of the Network Security Group"
  value       = azurerm_network_security_group.this.id
}

output "nsg_name" {
  description = "The name of the Network Security Group"
  value       = azurerm_network_security_group.this.name
}

output "applied_security_rules" {
  description = "List of configured security rules in this NSG"
  value       = azurerm_network_security_group.this.security_rule
}
