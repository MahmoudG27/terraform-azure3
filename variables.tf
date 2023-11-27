variable "rg-location" {
  type = string
}
variable "rg-name" {
  type = string
}
########################################
variable "address-vnet" {
  type = string
}
variable "address-subnet1" {
  type = string
}
variable "address-subnet2" {
  type = string
}
variable "name-vnet" {
  type = string
}
variable "name-subnet1" {
  type = string
}
variable "name-subnet2" {
  type = string
}
########################################
variable "nsg1-name" {
  type = string
}
variable "nsg2-name" {
  type = string
}
########################################
variable "sku-vm" {
  type = string
}
variable "offer-vm" {
  type = string
}
variable "vm-size" {
  type = string
}
variable "vm-version" {
  type = string
}
variable "admin-vm" {
  type = string
}
variable "adminpasswd-vm" {
  type = string
}
##########################################
variable "wp_private_ip_addresses" {
  type = list(string)
}
variable "mysql_private_ip_addresses" {
  type = list(string)
}
###########################################