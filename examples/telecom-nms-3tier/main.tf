terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.95.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Architect   = "Osama Khalil"
  })
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.name_prefix}"
  location = var.location
  tags     = local.common_tags
}

# 1. Virtual Network & Subnets Module with dynamic delegation
module "network" {
  source = "../../modules/vnet"

  vnet_name           = "vnet-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = var.vnet_address_space

  subnets = {
    "snet-backend-app" = {
      address_prefixes  = [var.backend_subnet_cidr]
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    }
    "snet-database" = {
      address_prefixes = [var.database_subnet_cidr]
      delegation = {
        name = "delegation-postgresql"
        service_delegation = {
          name    = "Microsoft.DBforPostgreSQL/flexibleServers"
          actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      }
    }
  }

  tags = local.common_tags
}

# 2. Network Security Groups with dynamic security rules
module "nsg_backend" {
  source = "../../modules/nsg"

  nsg_name            = "nsg-${local.name_prefix}-backend"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  security_rules = {
    "allow_https" = {
      name                       = "Allow-HTTPS-Inbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = var.backend_subnet_cidr
      description                = "Allow HTTPS traffic from frontend/clients"
    }
    "allow_http" = {
      name                       = "Allow-HTTP-Inbound"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "Internet"
      destination_address_prefix = var.backend_subnet_cidr
      description                = "Allow HTTP redirect to HTTPS"
    }
    "allow_ssh_bastion" = {
      name                       = "Allow-SSH-Internal"
      priority                   = 120
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "VirtualNetwork"
      destination_address_prefix = var.backend_subnet_cidr
      description                = "Allow SSH management strictly from internal VNet"
    }
  }

  subnet_associations = {
    "backend" = module.network.subnet_ids["snet-backend-app"]
  }

  tags = local.common_tags
}

module "nsg_database" {
  source = "../../modules/nsg"

  nsg_name            = "nsg-${local.name_prefix}-database"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  security_rules = {
    "allow_postgres_from_backend" = {
      name                       = "Allow-PostgreSQL-From-Backend"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "5432"
      source_address_prefix      = var.backend_subnet_cidr
      destination_address_prefix = var.database_subnet_cidr
      description                = "Allow PostgreSQL access strictly from snet-backend-app"
    }
    "deny_all_other_inbound" = {
      name                       = "Deny-All-Other-Inbound"
      priority                   = 999
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Default deny rule for database tier isolation"
    }
  }

  subnet_associations = {
    "database" = module.network.subnet_ids["snet-database"]
  }

  tags = local.common_tags
}

# 3. Frontend Azure Storage Static Website Module
module "frontend_storage" {
  source = "../../modules/storage_account"

  storage_account_name     = replace("st${local.name_prefix}web", "-", "")
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = var.storage_replication_type
  enable_static_website    = true
  index_document           = "index.html"
  error_404_document       = "404.html"

  tags = local.common_tags
}

# 4. Backend Linux Virtual Machine Module
module "backend_vm" {
  source = "../../modules/linux_vm"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  virtual_machines = {
    "vm-${local.name_prefix}-app" = {
      size                          = var.vm_size
      subnet_id                     = module.network.subnet_ids["snet-backend-app"]
      private_ip_address_allocation = "Static"
      private_ip_address            = var.backend_vm_private_ip
      admin_username                = var.admin_username
      ssh_public_key                = var.ssh_public_key
      enable_system_identity        = true

      os_disk = {
        caching              = "ReadWrite"
        storage_account_type = "Premium_LRS"
        disk_size_gb         = 64
      }

      source_image_reference = {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts-gen2"
        version   = "latest"
      }

      tags = {
        Tier = "BackendApp"
        Role = "Nginx-FastAPI"
      }
    }
  }

  tags = local.common_tags
}

# 5. Azure Database for PostgreSQL Flexible Server Module
module "database" {
  source = "../../modules/postgresql_flexible"

  server_name             = "psql-${local.name_prefix}"
  resource_group_name     = azurerm_resource_group.this.name
  location                = azurerm_resource_group.this.location
  postgres_version        = "15"
  delegated_subnet_id     = module.network.subnet_ids["snet-database"]
  administrator_login     = var.db_admin_username
  administrator_password  = var.db_admin_password
  sku_name                = var.db_sku_name
  storage_mb              = var.db_storage_mb
  backup_retention_days   = var.db_backup_retention_days

  databases = ["telecom_nms", "telecom_alarms"]

  configurations = {
    "work_mem"                  = "16MB"
    "shared_buffers"            = "256MB"
    "log_connections"           = "on"
    "log_disconnections"        = "on"
    "connection_throttling"     = "on"
  }

  tags = local.common_tags
}

# 6. Azure Key Vault Module for Secrets Management
module "key_vault" {
  source = "../../modules/key_vault"

  key_vault_name      = "kv-${local.name_prefix}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku_name            = "standard"

  secrets = {
    "db-admin-user" = var.db_admin_username
    "db-admin-pass" = var.db_admin_password
    "db-connection" = "postgresql://${var.db_admin_username}:${var.db_admin_password}@${module.database.server_fqdn}:5432/telecom_nms?sslmode=require"
  }

  tags = local.common_tags
}
