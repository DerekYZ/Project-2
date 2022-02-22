#Region 1 main
#Data calls
data "azuread_client_config" "main" {}

#resouce group region 1
resource "azurerm_resource_group" "trg1" {
  name     = var.team1rg1
  location = var.location
}

#network security group
resource "azurerm_network_security_group" "Network_Security_Group" {
  name                = var.network1_NSG
  location            = azurerm_resource_group.trg1.location
  resource_group_name = azurerm_resource_group.trg1.name

  security_rule {
    name                       = "allow-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 80
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-bastion"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-SQL"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#region 1 virtual network and subnets
resource "azurerm_virtual_network" "vnet1" {
  name                = var.region_01_virtual_network
  location            = azurerm_resource_group.trg1.location
  resource_group_name = azurerm_resource_group.trg1.name
  address_space       = var.address_space

  subnet {
    name           = var.subnet1
    address_prefix = var.subnet1_address 
    security_group = azurerm_network_security_group.Network_Security_Group.id
  }

  subnet {
    name           = var.subnet2
    address_prefix = var.subnet2_address
    security_group = azurerm_network_security_group.Network_Security_Group.id
  }
  subnet {
    name           = var.subnet3
    address_prefix = var.subnet3_address
    security_group = azurerm_network_security_group.Network_Security_Group.id
  }

  subnet {
    name           = var.subnet4
    address_prefix = var.subnet4_address
    security_group = azurerm_network_security_group.Network_Security_Group.id
  }

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