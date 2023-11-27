#Create Virtual Networks > Create Spoke Virtual Network
resource "azurerm_virtual_network" "terraform-vnet" {
  name                = var.name-vnet
  location            = var.rg-location
  resource_group_name = var.rg-name
  address_space       = [var.address-vnet]
  depends_on          = [azurerm_resource_group.terraform-rg]
}

#Create Subnet1 for VMs
resource "azurerm_subnet" "wp-subnet1" {
  name                 = var.name-subnet1
  resource_group_name  = var.rg-name
  virtual_network_name = azurerm_virtual_network.terraform-vnet.name
  address_prefixes     = [var.address-subnet1]
}

#Create Subnet2 for MySQL VMs
resource "azurerm_subnet" "mysql-subnet2" {
  name                 = var.name-subnet2
  resource_group_name  = var.rg-name
  virtual_network_name = azurerm_virtual_network.terraform-vnet.name
  address_prefixes     = [var.address-subnet2]
}