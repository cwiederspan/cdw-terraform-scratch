terraform {
  required_version = ">= 0.15"

  required_providers {
    azurerm = {
      version = "~> 2.62"
    }

    acme = {
      source  = "vancluever/acme"
      version = "~> 2.4"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.1.0"
    }
  }
}

provider "azurerm" {

  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "acme" {
  #server_url = "https://acme-v02.api.letsencrypt.org/directory"
  server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

provider "tls" {

}

variable "root_dns_name" {
  type        = string
  description = "The root domain name to be used for exposing the APIM site."
}

variable "dns_resource_group" {
  type        = string
  description = "The name of the Azure resource group that contains the DNS service being used for validation."
}

variable "contact_email" {
  description = "Email address for renewal notifications."
  type        = string
}

variable "az_sp_app_id" {
  description = "An Azure service principal application ID to use to verify DNS entries."
  type        = string
}

variable "az_sp_app_secret" {
  description = "The secret used with the service principal."
  type        = string
}

data "azurerm_client_config" "current" {}

# Generate a private key for LetsEncrypt account
resource "tls_private_key" "reg_private_key" {
  algorithm = "RSA"
}

# Create an LetsEncrypt registration
resource "acme_registration" "reg" {
  account_key_pem = tls_private_key.reg_private_key.private_key_pem
  email_address   = var.contact_email
}

resource "acme_certificate" "ssl" {
  account_key_pem = acme_registration.reg.account_key_pem
  common_name     = var.root_dns_name

  min_days_remaining = 60

  dns_challenge {
    provider = "azure"

    config = {
      AZURE_RESOURCE_GROUP = var.dns_resource_group

      AZURE_TENANT_ID       = data.azurerm_client_config.current.tenant_id
      AZURE_SUBSCRIPTION_ID = data.azurerm_client_config.current.subscription_id
      AZURE_CLIENT_ID       = var.az_sp_app_id
      AZURE_CLIENT_SECRET   = var.az_sp_app_secret
    }
  }
}

resource "local_file" "ssl-crt" {
  content  = acme_certificate.ssl.certificate_pem
  filename = "server.crt"
}

resource "local_file" "ssl-key" {
  content  = acme_certificate.ssl.private_key_pem
  filename = "server.key"
}