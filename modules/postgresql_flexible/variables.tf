variable "server_name" {
  description = "Name of the PostgreSQL Flexible Server"
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

variable "postgres_version" {
  description = "PostgreSQL major version"
  type        = string
  default     = "15"
}

variable "delegated_subnet_id" {
  description = "ID of delegated subnet for PostgreSQL flexible server (VNet integration)"
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "ID of private DNS zone for flexible server private link"
  type        = string
  default     = null
}

variable "administrator_login" {
  description = "Administrator username for PostgreSQL"
  type        = string
}

variable "administrator_password" {
  description = "Administrator password"
  type        = string
  sensitive   = true
}

variable "sku_name" {
  description = "Compute SKU tier"
  type        = string
  default     = "B_Standard_B2s"
}

variable "storage_mb" {
  description = "Allocated storage size in MB"
  type        = number
  default     = 32768
}

variable "backup_retention_days" {
  description = "Backup retention days (7-35)"
  type        = number
  default     = 7
}

variable "geo_redundant_backup_enabled" {
  description = "Enable geo-redundant backups"
  type        = bool
  default     = false
}

variable "high_availability" {
  description = "High availability configuration"
  type = object({
    mode                      = string
    standby_availability_zone = optional(string)
  })
  default = null
}

variable "databases" {
  description = "List of database names to provision automatically"
  type        = list(string)
  default     = ["telecom_nms"]
}

variable "configurations" {
  description = "Map of PostgreSQL server configurations / parameter tuning (e.g. work_mem, max_connections)"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags for the server"
  type        = map(string)
  default     = {}
}
