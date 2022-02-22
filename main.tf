#Region 1 main
#Data calls
data "azuread_client_config" "main" {}

#resouce group region 1
resource "azurerm_resource_group" "trg1" {
  name     = var.team1rg1
  location = var.location
}

#region 1 virtual network and subnets
resource "azurerm_virtual_network" "vnet1" {
  name                = var.region_01_virtual_network
  location            = azurerm_resource_group.trg1.location
  resource_group_name = azurerm_resource_group.trg1.name
  address_space       = var.address_space

  subnet {
    name           = "subnet1"
    address_prefix = "10.0.1.0/24"
  }

  subnet {
    name           = "subnet2"
    address_prefix = "10.0.2.0/24"
    #security_group = azurerm_network_security_group.network1_NSG.id
  }
  subnet {
    name           = "subnet3"
    address_prefix = "10.0.3.0/24"
    #security_group = azurerm_network_security_group.network1_NSG.id
  }
}
#bastion host
resource "azurerm_subnet" "subnet4" {
  name                 = "Bastion_Subnet"
  resource_group_name  = azurerm_resource_group.trg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["192.168.1.224/24"]
}

# resource "azurerm_public_ip" "bpip" {
#   name                = "bastion_pip"
#   location            = azurerm_resource_group.vnet1.location
#   resource_group_name = azurerm_resource_group.trg1.name
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }

# resource "azurerm_bastion_host" "rg1bastion" {
#   name                = "region_01_bastion"
#   location            = azurerm_resource_group.location.location
#   resource_group_name = azurerm_resource_group.trg1.name

#   ip_configuration {
#     name                 = "region_01_config"
#     subnet_id            = azurerm_subnet.subnet4.id
#     public_ip_address_id = azurerm_public_ip.bpip.id
#   }
# }
#network security group
resource "azurerm_network_security_group" "Network_Security_Group" {
  name                = var.network1_NSG
  location            = azurerm_resource_group.trg1.location
  resource_group_name = azurerm_resource_group.trg1.name
}