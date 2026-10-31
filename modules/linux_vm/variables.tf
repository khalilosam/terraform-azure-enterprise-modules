variable "resource_group_name" {
  description = "Resource group for the virtual machines"
  type        = string
}

variable "location" {
  description = "Azure region where the virtual machines are deployed"
  type        = string
}

variable "virtual_machines" {
  description = "Map of virtual machines configurations supporting dynamic disks, cloud-init, and SSH"
  type = map(object({
    size                            = string
    subnet_id                       = string
    private_ip_address_allocation   = optional(string, "Dynamic")
    private_ip_address              = optional(string)
    admin_username                  = string
    ssh_public_key                  = optional(string)
    custom_data_base64              = optional(string)
    enable_system_identity          = optional(bool, true)
    os_disk = object({
      caching              = string
      storage_account_type = string
      disk_size_gb         = optional(number)
    })
    source_image_reference = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
    tags = optional(map(string), {})
  }))
}

variable "tags" {
  description = "Global tags to merge with VM tags"
  type        = map(string)
  default     = {}
}
