terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.49.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "hvalfangst" {
  name     = "hvalfangstresourcegroup"
  location = "West Europe"
}

resource "azurerm_container_registry" "hvalfangst" {
  name                = "hvalfangstcontainerregistry"
  resource_group_name = azurerm_resource_group.hvalfangst.name
  location            = azurerm_resource_group.hvalfangst.location
  sku                 = "Basic"
  admin_enabled       = true
}

data "azurerm_client_config" "hvalfangst" {}

resource "azurerm_key_vault" "hvalfangst" {
  name                        = "hvalfangstkeyvault"
  location                    = azurerm_resource_group.hvalfangst.location
  resource_group_name         = azurerm_resource_group.hvalfangst.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.hvalfangst.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.hvalfangst.tenant_id
    object_id = data.azurerm_client_config.hvalfangst.object_id

    key_permissions = ["List", "Get", "Create", "Update", "Delete", "Purge"]
    secret_permissions =  ["List", "Get", "Set", "Delete", "Purge"]
  }
}

resource "azurerm_kubernetes_cluster" "hvalfangst" {
  name                = "hvalfangst-cluster"
  location            = azurerm_resource_group.hvalfangst.location
  resource_group_name = azurerm_resource_group.hvalfangst.name
  dns_prefix          = "hvalfangst"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.hvalfangst.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.hvalfangst.kube_config_raw
  sensitive = true
}