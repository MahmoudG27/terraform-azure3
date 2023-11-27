# Create an Azure public IP address For Load Balancer
resource "azurerm_public_ip" "lb-ip" {
  name                = "publicIPForLB"
  location            = var.rg-location
  resource_group_name = var.rg-name
  sku                 = "Standard"
  allocation_method   = "Static"
  depends_on          = [azurerm_resource_group.terraform-rg]
}

#Create Load Balancer
resource "azurerm_lb" "wp-lb" {
  name                = "wp-lb"
  location            = var.rg-location
  resource_group_name = var.rg-name
  sku                 = "Standard"
  depends_on          = [azurerm_virtual_machine.mysql-vm]

  frontend_ip_configuration {
    name                 = "wp3archlbfrontendip"
    public_ip_address_id = azurerm_public_ip.lb-ip.id
  }
}
#Create Loadbalancing Rules
resource "azurerm_lb_rule" "wp3arch-http-rules" {
  loadbalancer_id                = azurerm_lb.wp-lb.id
  name                           = "http-inbound-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "wp3archlbfrontendip"
  probe_id                       = azurerm_lb_probe.http-inbound-probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.wp3arch-backend-pool.id]
  disable_outbound_snat          = "true"
}
resource "azurerm_lb_rule" "wp3arch-https-rules" {
  loadbalancer_id                = azurerm_lb.wp-lb.id
  name                           = "https-inbound-rule"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "wp3archlbfrontendip"
  probe_id                       = azurerm_lb_probe.https-inbound-probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.wp3arch-backend-pool.id]
  disable_outbound_snat          = "true"
}

#Create Probe
resource "azurerm_lb_probe" "http-inbound-probe" {
  loadbalancer_id = azurerm_lb.wp-lb.id
  name            = "http-inbound-probe"
  port            = 80
}
resource "azurerm_lb_probe" "https-inbound-probe" {
  loadbalancer_id = azurerm_lb.wp-lb.id
  name            = "https-inbound-probe"
  port            = 443
}

#Create Backend Address Pool
resource "azurerm_lb_backend_address_pool" "wp3arch-backend-pool" {
  loadbalancer_id = azurerm_lb.wp-lb.id
  name            = "wp3arch-backend-pool"
}

resource "azurerm_lb_outbound_rule" "wp3arch-outbound" {
  name                    = "OutboundRule"
  loadbalancer_id         = azurerm_lb.wp-lb.id
  protocol                = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.wp3arch-backend-pool.id

  frontend_ip_configuration {
    name = "wp3archlbfrontendip"
  }
}

# Automated Backend Pool Addition > Gem Configuration to add the network interfaces of the VMs to the backend pool.
resource "azurerm_network_interface_backend_address_pool_association" "wp3arch-pool" {
  depends_on              = [azurerm_virtual_machine.wp-vm]
  count                   = 2
  network_interface_id    = azurerm_network_interface.wp-nic.*.id[count.index]
  ip_configuration_name   = azurerm_network_interface.wp-nic.*.ip_configuration.0.name[count.index]
  backend_address_pool_id = azurerm_lb_backend_address_pool.wp3arch-backend-pool.id
}