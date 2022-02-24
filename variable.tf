#credentails
variable "subscription_id" {
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
variable "resource_group_1" {
  type = string
}
variable "rg1_location" {
  type = string
}
#resouce group region 2
variable "resource_group_2" {
  type = string
}
variable "rg2_location" {
  type = string
}
#Network variables
variable "region_01_virtual_network" {
  type = string
}
variable "region_02_virtual_network" {
  type = string
}
variable "vnet1_address_space" {
  type = list(string)
}
variable "vnet2_address_space" {
  type = list(string)
}
variable "vnet1_NSG_name" {
  type = string
}
variable "vnet2_NSG_name" {
  type = string
}
variable "subnet1" {
  type = string
}
variable "subnet1_address" {
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
variable "subnet4_address" {
  type = string
}
variable "subnet6" {
  type = string
}
variable "subnet6_address" {
  type = string
}
variable "subnet7" {
  type = string
}
variable "subnet7_address" {
  type = string
}
variable "subnet8" {
  type = string
}
variable "subnet8_address" {
  type = string
}
variable "subnet9" {
  type = string
}
variable "subnet9_address" {
  type = string
}
variable "region_01_PIP" {
  type = string
}
variable "region_01_nic" {
  type = string
}
variable "private_balancer_apps_name" {
  type = string
}
variable "frontend_ip_configuration_name" {
  type = string
}
variable "fip_private_ip_address" {
  type = string
}
#app service plan
variable "app_plan" {
    type        = string
    description = "App Service Plan name in Azure"
}

variable "webapp" {
    type        = string
    description = "App Service name in Azure"
}

# variable "allocation_method" {
#   type = string
# }
# variable "bpip" {
#   type = string
# }
# variable "region_01_config" {
#   type = string
# }
