#credentails
variable "sub_id" {
  type = string
}
variable "client_id" {
  type = string
}
variable "client_secret" {
  type = string
}
variable "tenant_id" {
  type = string
}
#resouce group region 1
variable "team1rg1" {
  type = string
}
variable "location" {
  type = string
}
#Network variables
variable "region_01_virtual_network" {
  type = string
}
variable "address_space" {
  type = string
}
variable "network1_NSG" {
  type = string
}
variable "subnet1" {
  type = string
}
variable "subnet_address" {
  type = string
}
variable "subnet2" {
  type = string
}
variable "subnet2_address" {
    type = string
}
variable "subnet3" {
  type = string
}
variable "subnet3_address" {
  type = string
}
variable "subnet4" {
  type = string
}
variable "allocation_method" {
  type = string
}
variable "bpip" {
  type = string
}
variable "region_01_config" {
  type = string
}
