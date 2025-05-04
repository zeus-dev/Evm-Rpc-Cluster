module "network" {
  source              = "../modules/network"
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name                = "default"
    enable_auto_scaling = true
    min_count           = var.min_count
    max_count           = var.max_count
    vm_size             = var.vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    dns_service_ip     = "10.2.0.10"
    service_cidr       = "10.2.0.0/24"
    docker_bridge_cidr = "172.17.0.1/16"
  }
}
