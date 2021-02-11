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

/*
data "bigip_ltm_pool" "pool" {
  name = "${var.vs_name}-pool"
  partition = "Common" 
}
*/

resource "bigip_ltm_pool"  "pool" {
        name = "/Common/${var.vs_name}-pool"
        load_balancing_mode = "round-robin"
        monitors = ["/Common/http"]
        allow_snat = "yes"
        allow_nat = "yes"
}

resource "bigip_ltm_node" "nodeIP1" {
  name             = join("", list("/Common/",element(split(":", var.nodeIpAndPort),0)))
  address          = element(split(":", var.nodeIpAndPort),0)
  connection_limit = "0"
  dynamic_ratio    = "1"
  monitor          = "/Common/icmp"
  description      = "${var.vs_name}-Node1"
  rate_limit       = "disabled"
  fqdn {
    address_family = "ipv4"
    interval       = "3000"
  }
}

resource "bigip_ltm_pool_attachment" "attach_node" {
        pool = bigip_ltm_pool.pool.name
        node = join(":", list(bigip_ltm_node.nodeIP1.name, element(split(":", var.nodeIpAndPort),1)))
        depends_on = [bigip_ltm_pool.pool, bigip_ltm_node.nodeIP1]
}

/*
resource "bigip_ltm_pool_attachment" "attach_node2" {
        pool = "/Common/${var.vs_name}-pool"
        node = "172.17.102.205:80"
        #depends_on = [bigip_ltm_pool.pool]
}
*/
resource "bigip_ltm_virtual_server" "httpredir" {
        name = "/Common/${var.vs_name}_vs_httpredir"
        destination = var.vs_ip
        port = 80
        source_address_translation = "automap"
        ip_protocol = "tcp"
        irules = ["/Common/_sys_https_redirect"]
        profiles = [ "/Common/tcp", "/Common/http" ]
}
resource "bigip_ltm_virtual_server" "https" {
        #pool = data.bigip_ltm_pool.pool.full_path
        pool = bigip_ltm_pool.pool.name
        name = "/Common/${var.vs_name}_vs_https"
        destination = var.vs_ip
        port = 443
        source_address_translation = "automap"
        ip_protocol = "tcp"
        #irules = ["/Common/maintenance-page_irule"]
        profiles = [ "/Common/tcp", "/Common/http" ]
        client_profiles            = ["/Common/clientssl"]
        #server_profiles            = ["/Common/serverssl"]
        depends_on = [bigip_ltm_pool.pool]
}
