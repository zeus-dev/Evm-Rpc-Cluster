# terraform/modules/network/outputs.tf
output "subnet_id" {
  value = azurerm_subnet.subnet.id
}
#terraform init 
#terraform apply -var='aks_name=your-cluster' -var='resource_group_name=your-rg' -var='location=your-region' -var='dns_prefix=yourprefix'
