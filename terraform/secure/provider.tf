terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.68.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "1.4.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.19.0-beta.5"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.8.0"
    }
  }
}

provider "sops" {}

data "sops_file" "ssh_info" {
  source_file = "../../secrets/ssh_info.enc.yaml"
}
data "sops_file" "cloudflare" {
  source_file = "../../secrets/cloudflare.enc.yaml"
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
      recover_soft_deleted_keys          = true
    }
  }
}

provider "cloudflare" {
  api_token = data.sops_file.cloudflare.data["api_key"]
}

resource "azurerm_resource_group" "secure1-rg-nz" {
  name     = "secure1-rg-nz"
  location = "New Zealand North"
}

data "azurerm_client_config" "current" {}