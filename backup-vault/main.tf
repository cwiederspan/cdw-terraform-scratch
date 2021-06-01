terraform {
  required_version = ">= 0.15"

  required_providers {
    
    azurerm = {
      version = "~> 2.61"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "cdw-backups-20210528"
  location = "eastus2"
}

resource "azurerm_recovery_services_vault" "vault" {
  name                = "cdw-backups-20210528-vault"
  location            = "eastus2"
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  soft_delete_enabled = true
}

resource "azurerm_backup_policy_vm" "policy" {
  name                = "pol-vms-scentralus"
  resource_group_name = azurerm_resource_group.rg.name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name

  timezone = "Central Standard Time"

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 8
  }
}
