variable "aks_name" {}
variable "resource_group_name" {}
variable "location" {}
variable "dns_prefix" {}
variable "min_count" {
  default = 2
}
variable "max_count" {
  default = 5
}
variable "vm_size" {
  default = "Standard_DS2_v2"
}

# terraform/aks/outputs.tf
output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}