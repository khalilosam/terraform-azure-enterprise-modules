terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.90.0, < 4.0.0"
    }
  }
}

resource "azurerm_network_interface" "this" {
  for_each = var.virtual_machines

  name                = "${each.key}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = merge(var.tags, lookup(each.value, "tags", {}))

  ip_configuration {
    name                          = "internal"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = lookup(each.value, "private_ip_address_allocation", "Dynamic")
    private_ip_address            = lookup(each.value, "private_ip_address", null)
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  for_each = var.virtual_machines

  name                            = each.key
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = each.value.size
  admin_username                  = each.value.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.this[each.key].id]
  custom_data                     = lookup(each.value, "custom_data_base64", null)
  tags                            = merge(var.tags, lookup(each.value, "tags", {}))

  dynamic "admin_ssh_key" {
    for_each = each.value.ssh_public_key != null && each.value.ssh_public_key != "" ? [1] : []
    content {
      username   = each.value.admin_username
      public_key = each.value.ssh_public_key
    }
  }

  os_disk {
    caching              = each.value.os_disk.caching
    storage_account_type = each.value.os_disk.storage_account_type
    disk_size_gb         = lookup(each.value.os_disk, "disk_size_gb", null)
  }

  source_image_reference {
    publisher = each.value.source_image_reference.publisher
    offer     = each.value.source_image_reference.offer
    sku       = each.value.source_image_reference.sku
    version   = each.value.source_image_reference.version
  }

  dynamic "identity" {
    for_each = lookup(each.value, "enable_system_identity", true) ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }
}
