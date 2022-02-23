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
  address_prefix       = var.subnet1_address
}
resource "azurerm_subnet" "subnet2" {
  name                 = var.subnet2
  resource_group_name  = azurerm_resource_group.trg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefix       = var.subnet2_address
}
resource "azurerm_subnet" "subnet3" {
  name                 = var.subnet3
  resource_group_name  = azurerm_resource_group.trg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefix       = var.subnet3_address
}
resource "azurerm_subnet" "subnet4" {
  name                 = var.subnet4
  resource_group_name  = azurerm_resource_group.trg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefix       = var.subnet4_address
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

#VM scale set in bussiness tier/ subnet2
resource "azurerm_linux_virtual_machine_scale_set" "VMss" {
  name                = "VMss"
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

#NIC
resource "azurerm_network_interface" "r1nic" {
  name                = "region_01_nic"
  location            = azurerm_resource_group.trg1.location
  resource_group_name = azurerm_resource_group.trg1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet3.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.region_01_PIP.id
  }
}
#PIP
resource "azurerm_public_ip" "region_01_PIP" {
  name                = "region_01_PIP"
  resource_group_name = azurerm_resource_group.trg1.name
  location            = azurerm_resource_group.trg1.location
  allocation_method   = "Dynamic"
}

#********************************************************FIRST INTERNAL LOAD BALANCER************************************************************
#Private Load Balancer. (this is the deployment of load balancer )
resource "azurerm_lb" "Private_Balancer_apps" {
  name                = var.private_balancer_apps_name
  resource_group_name = azurerm_resource_group.trg1.name
  location            = azurerm_resource_group.trg1.location

  frontend_ip_configuration {
    name                          = var.frontend_ip_configuration_name
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.fip_private_ip_address
  }

}

#deployment of backend address pool
resource "azurerm_lb_backend_address_pool" "PLB_Backend1" {
  loadbalancer_id = azurerm_lb.Private_Balancer_apps.id
  name            = "PLB_BE1"
}

#deployment of LoadBalancer Health Probe.
resource "azurerm_lb_probe" "PrivateLB_Probe1" {
  resource_group_name = var.team1rg1
  loadbalancer_id     = azurerm_lb.Private_Balancer_apps.id
  name                = "ssh-running-probe"
  port                = 22
}
#depoloyment of Load Balancer Rule.
resource "azurerm_lb_rule" "lb-rule" {
  resource_group_name            = azurerm_resource_group.trg1.name
  loadbalancer_id                = azurerm_lb.Private_Balancer_apps.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = var.frontend_ip_configuration_name
  backend_address_pool_id        = azurerm_lb_backend_address_pool.PLB_Backend1.id
  probe_id                       = azurerm_lb_probe.PrivateLB_Probe1.id
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