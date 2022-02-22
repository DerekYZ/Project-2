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

#region 1 virtual network
resource "azurerm_virtual_network" "vnet1" {
  name                = var.region_01_virtual_network
  location            = azurerm_resource_group.trg1.location
  resource_group_name = azurerm_resource_group.trg1.name
  address_space       = var.address_space
}

#subnets
resource "azurerm_subnet" "subnet1" {
  name                 = var.subnet1
  resource_group_name  = azurerm_resource_group.trg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefix     = var.subnet1_address
}
resource "azurerm_subnet" "subnet2" {
  name                 = var.subnet2
  resource_group_name  = azurerm_resource_group.trg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefix     = var.subnet2_address
}
resource "azurerm_subnet" "subnet3" {
  name                 = var.subnet3
  resource_group_name  = azurerm_resource_group.trg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefix     = var.subnet3_address
}
resource "azurerm_subnet" "subnet4" {
  name                 = var.subnet4
  resource_group_name  = azurerm_resource_group.trg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefix     = var.subnet4_address
}

#associate NSG to subnets
resource "azurerm_subnet_network_security_group_association" "associate_nsg_subnet1" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.Network_Security_Group.id
}
resource "azurerm_subnet_network_security_group_association" "associate_nsg_subnet2" {
  subnet_id                 = azurerm_subnet.subnet2.id
  network_security_group_id = azurerm_network_security_group.Network_Security_Group.id
}
resource "azurerm_subnet_network_security_group_association" "associate_nsg_subnet3" {
  subnet_id                 = azurerm_subnet.subnet3.id
  network_security_group_id = azurerm_network_security_group.Network_Security_Group.id
}
resource "azurerm_subnet_network_security_group_association" "associate_nsg_subnet4" {
  subnet_id                 = azurerm_subnet.subnet4.id
  network_security_group_id = azurerm_network_security_group.Network_Security_Group.id
}

#VM scale set in web tier/ subnet1
resource "azurerm_linux_virtual_machine_scale_set" "VMss1" {
  name                = "VMss1"
  resource_group_name = azurerm_resource_group.trg1.name
  location            = azurerm_resource_group.trg1.location
  sku                 = "Standard_B1s"
  instances           = 3
  admin_username      = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "example"
    primary = true

    ip_configuration {
      name      = "internal"
      subnet_id = azurerm_subnet.subnet1.id
    }
  }
}

#VM scale set in bussiness tier/ subnet2
resource "azurerm_linux_virtual_machine_scale_set" "VMss2" {
  name                = "VMss2"
  resource_group_name = azurerm_resource_group.trg1.name
  location            = azurerm_resource_group.trg1.location
  sku                 = "Standard_B1s"
  instances           = 3
  admin_username      = "azureuser"

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "example"
    primary = true

    ip_configuration {
      name      = "internal"
      subnet_id = azurerm_subnet.subnet2.id
    }
  }
}

# resource "azurerm_public_ip" "bpip" {
#   name                = "bastion_pip"
#   location            = azurerm_resource_group.trg1.location
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