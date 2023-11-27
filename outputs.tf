# Output load balancer public IP
output "lb_public_ip" {
  value = azurerm_public_ip.lb-ip.ip_address
}

output "mysql_lb_private_ip" {
  value = azurerm_lb.mysql-lb.frontend_ip_configuration[0].private_ip_address
}

# Get private IP of wp VM0
output "wp-vm0_private_ip" {
  value = azurerm_network_interface.wp-nic[0].private_ip_address
}

# Get private IP of wp VM1 
output "wp-vm1_private_ip" {
  value = azurerm_network_interface.wp-nic[1].private_ip_address
}

# Get private IP of mysql VM0
output "mysql-vm0_private_ip" {
  value = azurerm_network_interface.mysql-nic[0].private_ip_address
}

# Get private IP of mysql VM1
output "mysql-vm1_private_ip" {
  value = azurerm_network_interface.mysql-nic[1].private_ip_address
}