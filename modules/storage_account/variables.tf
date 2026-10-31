variable "storage_account_name" {
  description = "Globally unique name of the storage account (lowercase alphanumeric 3-24 chars)"
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

variable "account_tier" {
  description = "Tier to use for this storage account (Standard or Premium)"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Replication type (LRS, GRS, RAGRS, ZRS)"
  type        = string
  default     = "LRS"
}

variable "enable_static_website" {
  description = "Whether to enable the static website hosting feature ($web container)"
  type        = bool
  default     = false
}

variable "index_document" {
  description = "Index document path for static website"
  type        = string
  default     = "index.html"
}

variable "error_404_document" {
  description = "404 document path for static website"
  type        = string
  default     = "404.html"
}

variable "network_rules" {
  description = "Network rules for restricting storage account access"
  type = object({
    default_action             = string
    bypass                     = optional(list(string), ["AzureServices"])
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = null
}

variable "containers" {
  description = "Map of blob containers to provision with their access type"
  type = map(object({
    access_type = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags for the storage account"
  type        = map(string)
  default     = {}
}
