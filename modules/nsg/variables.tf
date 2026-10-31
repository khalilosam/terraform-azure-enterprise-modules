variable "nsg_name" {
  description = "Name of the Network Security Group"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the NSG"
  type        = string
}

variable "security_rules" {
  description = "Map of security rules to inject dynamically into the Network Security Group"
  type = map(object({
    name                         = string
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_range            = optional(string)
    source_port_ranges           = optional(list(string))
    destination_port_range       = optional(string)
    destination_port_ranges      = optional(list(string))
    source_address_prefix        = optional(string)
    source_address_prefixes      = optional(list(string))
    destination_address_prefix   = optional(string)
    destination_address_prefixes = optional(list(string))
    description                  = optional(string)
  }))
  default = {}
}

variable "subnet_associations" {
  description = "Map of subnet IDs to associate with this Network Security Group"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to assign to the NSG"
  type        = map(string)
  default     = {}
}
