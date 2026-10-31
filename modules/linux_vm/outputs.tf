output "vm_ids" {
  description = "Map of virtual machine names to their resource IDs"
  value       = { for k, v in azurerm_linux_virtual_machine.this : k => v.id }
}

output "vm_private_ips" {
  description = "Map of virtual machine names to their private IP addresses"
  value       = { for k, v in azurerm_linux_virtual_machine.this : k => v.private_ip_address }
}

output "nic_ids" {
  description = "Map of virtual machine names to their network interface IDs"
  value       = { for k, v in azurerm_network_interface.this : k => v.id }
}

output "principal_ids" {
  description = "Map of system-assigned managed identity principal IDs for RBAC assignment"
  value       = { for k, v in azurerm_linux_virtual_machine.this : k => try(v.identity[0].principal_id, null) }
}
