#Region 1 main
#Data calls
data "azuread_client_config" "main" {}

#resouce group 1 for primary region
resource "azurerm_resource_group" "rg1" {
  name     = var.resource_group_1
  location = var.rg1_location
}

#vnet1 network security group
resource "azurerm_network_security_group" "vnet1_Network_Security_Group" {
  name                = var.vnet1_NSG_name
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

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
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  address_space       = var.vnet1_address_space
}

#subnets
resource "azurerm_subnet" "subnet1" {
  name                 = var.subnet1
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefix       = var.subnet1_address
}
resource "azurerm_subnet" "subnet2" {
  name                 = var.subnet2
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefix       = var.subnet2_address
}
resource "azurerm_subnet" "subnet3" {
  name                 = var.subnet3
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefix       = var.subnet3_address
}
resource "azurerm_subnet" "subnet4" {
  name                 = var.subnet4
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefix       = var.subnet4_address
}

#associate NSG to subnets
resource "azurerm_subnet_network_security_group_association" "associate_nsg_subnet1" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.vnet1_Network_Security_Group.id
}
resource "azurerm_subnet_network_security_group_association" "associate_nsg_subnet2" {
  subnet_id                 = azurerm_subnet.subnet2.id
  network_security_group_id = azurerm_network_security_group.vnet1_Network_Security_Group.id
}
resource "azurerm_subnet_network_security_group_association" "associate_nsg_subnet3" {
  subnet_id                 = azurerm_subnet.subnet3.id
  network_security_group_id = azurerm_network_security_group.vnet1_Network_Security_Group.id
}
resource "azurerm_subnet_network_security_group_association" "associate_nsg_subnet4" {
  subnet_id                 = azurerm_subnet.subnet4.id
  network_security_group_id = azurerm_network_security_group.vnet1_Network_Security_Group.id
}

#VM scale set in bussiness tier/ subnet2
resource "azurerm_linux_virtual_machine_scale_set" "VMss" {
  name                = "VMss"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
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
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet3.id
    private_ip_address_allocation = "Dynamic"
    #public_ip_address_id          = azurerm_public_ip.region_01_PIP.id
  }
}

#********************************************************FIRST INTERNAL LOAD BALANCER************************************************************
#Private Load Balancer. (this is the deployment of load balancer )
resource "azurerm_lb" "Private_Balancer_apps" {
  name                = var.private_balancer_apps_name
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location

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
  resource_group_name = azurerm_resource_group.rg1.name
  loadbalancer_id     = azurerm_lb.Private_Balancer_apps.id
  name                = "ssh-running-probe"
  port                = 22
}
#depoloyment of Load Balancer Rule.
resource "azurerm_lb_rule" "lb-rule" {
  resource_group_name            = azurerm_resource_group.rg1.name
  loadbalancer_id                = azurerm_lb.Private_Balancer_apps.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 22
  backend_port                   = 22
  frontend_ip_configuration_name = var.frontend_ip_configuration_name
  backend_address_pool_id        = azurerm_lb_backend_address_pool.PLB_Backend1.id
  probe_id                       = azurerm_lb_probe.PrivateLB_Probe1.id
}

#bastion network interface 
resource "azurerm_network_interface" "east_bastion_nic" {
  name                = "east_bastion_nic"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  ip_configuration {
    name                          = "east-bstn-nic-cfg"
    subnet_id                     = azurerm_subnet.subnet4.id
    private_ip_address_allocation = "Dynamic"
  }
}

# bastion host VM
resource "azurerm_windows_virtual_machine" "eastbastionvm" {
  name                = "east-bation-vm"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  size                = "Standard_B1s"
  admin_username      = "azureuser"
  admin_password      = "Pa55w.rd"
  network_interface_ids = [
    azurerm_network_interface.east_bastion_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

#######################################################################################################
#resouce group 2 for secondary region
resource "azurerm_resource_group" "rg2" {
  name     = var.resource_group_2
  location = var.rg2_location
}

#vnet2 network security group
resource "azurerm_network_security_group" "vnet2_Network_Security_Group" {
  name                = var.vnet2_NSG_name
  location            = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name

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
################      app services ############
resource "azurerm_app_service" "webapp" {
  name                = var.webapp
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  app_service_plan_id = azurerm_app_service_plan.app_plan.id

  connection_string {
    name  = "Database"
    type  = "SQLServer"
    #value = "Server=some-server.mydomain.com;Integrated Security=SSPI"
  }
}
######################################## SQL Server and Database  #####################
resource "azurerm_sql_server" "sqls1db" {
  name                         = var.region_01_sql
  resource_group_name          = azurerm_resource_group.rg1.name
  location                     = azurerm_resource_group.rg1.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_sql_database" "r1db1" {
  name                = "team1-database1"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  server_name         = azurerm_sql_server.sqls1db.name
}
resource "azurerm_sql_database" "r1db2" {
  name                = "team1-database2"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  server_name         = azurerm_sql_server.sqls1db.name
}
#region 2 virtual network
resource "azurerm_virtual_network" "vnet2" {
  name                = var.region_02_virtual_network
  location            = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name
  address_space       = var.vnet2_address_space
}

#subnets
resource "azurerm_subnet" "subnet6" {
  name                 = var.subnet6
  resource_group_name  = azurerm_resource_group.rg2.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefix       = var.subnet6_address
}
resource "azurerm_subnet" "subnet7" {
  name                 = var.subnet7
  resource_group_name  = azurerm_resource_group.rg2.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefix       = var.subnet7_address
}
resource "azurerm_subnet" "subnet8" {
  name                 = var.subnet8
  resource_group_name  = azurerm_resource_group.rg2.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefix       = var.subnet8_address
}
resource "azurerm_subnet" "subnet9" {
  name                 = var.subnet9
  resource_group_name  = azurerm_resource_group.rg2.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefix       = var.subnet9_address
}

# #associate NSG to subnets
resource "azurerm_subnet_network_security_group_association" "associate_nsg_subnet6" {
  subnet_id                 = azurerm_subnet.subnet6.id
  network_security_group_id = azurerm_network_security_group.vnet2_Network_Security_Group.id
}
resource "azurerm_subnet_network_security_group_association" "associate_nsg_subnet7" {
  subnet_id                 = azurerm_subnet.subnet7.id
  network_security_group_id = azurerm_network_security_group.vnet2_Network_Security_Group.id
}
resource "azurerm_subnet_network_security_group_association" "associate_nsg_subnet8" {
  subnet_id                 = azurerm_subnet.subnet8.id
  network_security_group_id = azurerm_network_security_group.vnet2_Network_Security_Group.id
}
resource "azurerm_subnet_network_security_group_association" "associate_nsg_subnet9" {
  subnet_id                 = azurerm_subnet.subnet9.id
  network_security_group_id = azurerm_network_security_group.vnet2_Network_Security_Group.id
}

#vnet peering
resource "azurerm_virtual_network_peering" "peering1" {
  name                      = "peer1to2"
  resource_group_name       = azurerm_resource_group.rg1.name
  virtual_network_name      = azurerm_virtual_network.vnet1.name
  remote_virtual_network_id = azurerm_virtual_network.vnet2.id
}

resource "azurerm_virtual_network_peering" "peering2" {
  name                      = "peer2to1"
  resource_group_name       = azurerm_resource_group.rg2.name
  virtual_network_name      = azurerm_virtual_network.vnet2.name
  remote_virtual_network_id = azurerm_virtual_network.vnet1.id
}