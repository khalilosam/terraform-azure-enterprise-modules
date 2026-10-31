variable "key_vault_name" {
  description = "Globally unique name of Key Vault"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "sku_name" {
  description = "SKU for Key Vault (standard or premium)"
  type        = string
  default     = "standard"
}

variable "access_policies" {
  description = "Map of access policies dynamically applied for principals (Users, SPNs, Managed Identities)"
  type = map(object({
    object_id               = string
    key_permissions         = optional(list(string), [])
    secret_permissions      = optional(list(string), [])
    certificate_permissions = optional(list(string), [])
  }))
  default = {}
}

variable "network_acls" {
  description = "Network ACLs for Key Vault access restrictions"
  type = object({
    default_action             = string
    bypass                     = string
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = null
}

variable "secrets" {
  description = "Map of secret names to sensitive values to store"
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "tags" {
  description = "Tags for the Key Vault"
  type        = map(string)
  default     = {}
}
