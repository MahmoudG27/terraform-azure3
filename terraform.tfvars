rg-location = "North Europe"
rg-name     = "terraform"

address-vnet    = "10.1.0.0/16"
address-subnet1 = "10.1.1.0/24"
address-subnet2 = "10.1.2.0/24"
name-vnet       = "terraform-vnet"
name-subnet1    = "wp-subnet"
name-subnet2    = "mysql-subnet"

nsg1-name = "wp-nsg"
nsg2-name = "mysql-nsg"

offer-vm       = "0001-com-ubuntu-server-focal"
sku-vm         = "20_04-lts"
vm-size        = "Standard_DS2_v2"
vm-version     = "latest"
admin-vm       = "mahmoud"
adminpasswd-vm = "Password123@"

wp_private_ip_addresses    = ["10.1.1.4", "10.1.1.5"]
mysql_private_ip_addresses = ["10.1.2.4", "10.1.2.5"]