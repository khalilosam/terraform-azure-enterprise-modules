# Terraform Azure Enterprise Modules Library

[![Terraform](https://img.shields.io/badge/Terraform->=1.5.0-blue.svg?style=flat&logo=terraform)](https://www.terraform.io/)
[![Azure Provider](https://img.shields.io/badge/azurerm-~>3.90-0078d4.svg?style=flat&logo=microsoft-azure)](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
[![IaC Security](https://img.shields.io/badge/Security-Checkov%20%7C%20tfsec-brightgreen.svg?style=flat)](https://github.com/bridgecrewio/checkov)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

> **Architected by Osama Khalil** | Senior DevOps Engineer & Cloud Solution Architect  
> *Production-grade, highly scalable Terraform modules built using `for_each`, nested dynamic blocks, complex map typing, and strict validation.*

---

## 🏛️ Architectural Overview

This repository provides an enterprise-standard, composable Infrastructure as Code (IaC) library for provisioning mission-critical cloud infrastructure on **Microsoft Azure**.

All modules strictly adhere to HashiCorp best practices:
* **Zero Hardcoding:** Complete parametrization with strongly typed maps, lists, and objects.
* **Declarative Scaling with `for_each`:** Multi-subnet generation, dynamic multi-rule NSG provisioning, and multi-database provisioning.
* **Metaprogramming with `dynamic` Blocks:** Fully dynamic `security_rule`, `delegation`, `identity`, `network_rules`, `access_policy`, and `high_availability` blocks.
* **Enterprise Security Standards:** Zero public database exposure, TLS 1.2+ mandatory enforcement, and customer-managed secrets in Azure Key Vault.

---

## 📦 Module Registry

| Module Path | Core Features | Advanced Terraform Syntax |
| :--- | :--- | :--- |
| [`modules/vnet`](./modules/vnet) | Azure Virtual Network with dynamically declared subnets, CIDR calculations, and service endpoints. | `for_each = var.subnets`, `dynamic "delegation"` |
| [`modules/nsg`](./modules/nsg) | Network Security Groups with granular rule injections and subnet associations. | `dynamic "security_rule"`, `for_each = var.subnet_associations` |
| [`modules/linux_vm`](./modules/linux_vm) | Enterprise Linux VMs (RHEL/Ubuntu) with managed identities, NIC binding, and cloud-init scripts. | `for_each = var.virtual_machines`, `dynamic "admin_ssh_key"` |
| [`modules/postgresql_flexible`](./modules/postgresql_flexible) | Azure PostgreSQL Flexible Server with delegated VNet integration, private DNS, and server parameter tuning. | `dynamic "high_availability"`, `for_each = var.configurations` |
| [`modules/storage_account`](./modules/storage_account) | Storage Account with static website hosting (`$web`), network ACLs, and blob container automation. | `dynamic "static_website"`, `dynamic "network_rules"` |
| [`modules/key_vault`](./modules/key_vault) | Azure Key Vault with dynamic access policies, network ACLs, and automated secret ingestion. | `dynamic "access_policy"`, `for_each = var.secrets` |

---

## 🚀 Complete 3-Tier Telecom NMS Implementation

See [`examples/telecom-nms-3tier`](./examples/telecom-nms-3tier) for the end-to-end production deployment showing module composition across Dev, Stage, and Prod environments.

```bash
# Initialize with Azure Blob Storage remote backend
terraform init -backend-config="storage_account_name=sttfstateprod01" \
               -backend-config="container_name=tfstate" \
               -backend-config="key=dev.terraform.tfstate"

# Generate speculative execution plan
terraform plan -var-file="environments/dev/terraform.tfvars" -out=dev.tfplan

# Apply approved plan
terraform apply dev.tfplan
```

---

## 🛡️ Shift-Left Quality & Compliance

Run automated security and lint checks:
```bash
# Check formatting
terraform fmt -check -recursive

# Run TFLint
tflint --init && tflint

# Run Checkov security scanning
checkov -d . --framework terraform
```

---

## 👨‍💻 Author

**Osama Khalil**
- **Role:** Senior DevOps Engineer | Microsoft Azure | Terraform | CI/CD | Linux
- **GitHub:** [@khalilosam](https://github.com/khalilosam)
- **LinkedIn:** [linkedin.com/in/osama-khalil-20525227](https://www.linkedin.com/in/osama-khalil-20525227/)
