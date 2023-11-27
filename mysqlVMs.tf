#Create Private Network Interfaces
resource "azurerm_network_interface" "mysql-nic" {
  count               = 2
  name                = "mysql-nic-${count.index}"
  location            = var.rg-location
  resource_group_name = var.rg-name

  ip_configuration {
    name                          = "mysql-nic-config-${count.index}"
    subnet_id                     = azurerm_subnet.mysql-subnet2.id
    private_ip_address_allocation = "Static"
    private_ip_address            = element(var.mysql_private_ip_addresses, count.index)
  }
}

# Create two Azure virtual machines
resource "azurerm_virtual_machine" "mysql-vm" {
  count                 = 2
  name                  = "mysql-vm-${count.index}"
  location              = var.rg-location
  resource_group_name   = var.rg-name
  network_interface_ids = [azurerm_network_interface.mysql-nic[count.index].id]
  vm_size               = var.vm-size

  storage_image_reference {
    publisher = "Canonical"
    offer     = var.offer-vm
    sku       = var.sku-vm
    version   = var.vm-version
  }

  storage_os_disk {
    name              = "mysql-vm-disk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "mysql-vm-${count.index}"
    admin_username = var.admin-vm
    admin_password = var.adminpasswd-vm
    custom_data    = file("master.sh")
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}