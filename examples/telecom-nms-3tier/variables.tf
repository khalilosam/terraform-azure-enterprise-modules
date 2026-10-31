variable "project_name" {
  description = "Project identifier"
  type        = string
  default     = "telecom-nms"
}

variable "environment" {
  description = "Deployment environment (dev, stage, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Environment must be one of: dev, stage, prod."
  }
}

variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "eastus"
}

variable "vnet_address_space" {
  description = "Virtual network address space"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "backend_subnet_cidr" {
  description = "Subnet CIDR for backend application VM"
  type        = string
  default     = "10.0.2.0/24"
}

variable "database_subnet_cidr" {
  description = "Subnet CIDR for delegated PostgreSQL Flexible Server"
  type        = string
  default     = "10.0.3.0/24"
}

variable "backend_vm_private_ip" {
  description = "Static private IP address for backend Linux VM"
  type        = string
  default     = "10.0.2.10"
}

variable "vm_size" {
  description = "Size of backend Linux VM"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Admin username for Linux VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key for VM authentication"
  type        = string
  default     = ""
}

variable "db_admin_username" {
  description = "Administrator login for PostgreSQL"
  type        = string
  default     = "telecom_admin"
}

variable "db_admin_password" {
  description = "Administrator password for PostgreSQL"
  type        = string
  sensitive   = true
}

variable "db_sku_name" {
  description = "PostgreSQL compute SKU"
  type        = string
  default     = "B_Standard_B2s"
}

variable "db_storage_mb" {
  description = "Storage in MB for PostgreSQL"
  type        = number
  default     = 32768
}

variable "db_backup_retention_days" {
  description = "Backup retention in days"
  type        = number
  default     = 7
}

variable "storage_replication_type" {
  description = "Storage account replication (LRS, ZRS, GRS)"
  type        = string
  default     = "LRS"
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
