# Configure the bigip provider
terraform {
  required_providers {
    bigip = {
      source = "f5networks/bigip"
      version = ">= 1.6.0"
    }
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.13.0"
    }
  }
 }

provider "azurerm" {
  subscription_id = "<Your Subscription Id>"
  features {}
}

data "azurerm_key_vault" "example" {
	name = "<Your Vault Name>"
	resource_group_name = "<Your Resource Group Name>"
}

data "azurerm_key_vault_secret" "test" {
  name      = "<Your Secret Name>"
  key_vault_id = data.azurerm_key_vault.example.id
}

provider "bigip" {
    address = var.bigip_host
    username = var.bigip_username
    password = data.azurerm_key_vault_secret.test.value
    #var.bigip_password
}

# Loading from a file is the preferred method
resource "bigip_ltm_irule" "maintenance-page" {
  name  = "/Common/maintenance-page_irule"
  irule = file("maintenance-page.tcl")
}

/*
resource "bigip_ltm_virtual_server" "http" {
        name = "/Common/${var.vs_name}_vs_http"
        #irule = ["/Common/maintenance-page_irule"]
        irules = [ bigip_ltm_irule.maintenance-page.name ]
        destination = var.vs_ip
        port = 80
        depends_on = [bigip_ltm_irule.maintenance-page]
}*/