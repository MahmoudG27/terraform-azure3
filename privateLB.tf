resource "azurerm_lb" "mysql-lb" {
  name                = "mysql-lb"
  resource_group_name = var.rg-name
  location            = var.rg-location
  sku                 = "Standard"
  frontend_ip_configuration {
    name                          = "mysqllbfrontendip"
    subnet_id                     = azurerm_subnet.mysql-subnet2.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.2.10"
  }
}

resource "azurerm_lb_rule" "mysql-lb-rule" {
  loadbalancer_id                = azurerm_lb.mysql-lb.id
  name                           = "mysql-lb-rule"
  protocol                       = "Tcp"
  frontend_port                  = 3306
  backend_port                   = 3306
  frontend_ip_configuration_name = "mysqllbfrontendip"
  probe_id                       = azurerm_lb_probe.mysql-lb-probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.mysql-lb-backend.id]
  disable_outbound_snat          = "true"
}

resource "azurerm_lb_probe" "mysql-lb-probe" {
  loadbalancer_id = azurerm_lb.mysql-lb.id
  name            = "mysql-port"
  port            = 3306
}

resource "azurerm_lb_backend_address_pool" "mysql-lb-backend" {
  name            = "mysql-lb-backend"
  loadbalancer_id = azurerm_lb.mysql-lb.id
}

resource "azurerm_network_interface_backend_address_pool_association" "mysql-pool" {
  depends_on              = [azurerm_virtual_machine.wp-vm]
  count                   = 2
  network_interface_id    = azurerm_network_interface.mysql-nic.*.id[count.index]
  ip_configuration_name   = azurerm_network_interface.mysql-nic.*.ip_configuration.0.name[count.index]
  backend_address_pool_id = azurerm_lb_backend_address_pool.mysql-lb-backend.id
}