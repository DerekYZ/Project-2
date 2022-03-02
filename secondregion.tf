#resouce group 2 for secondary region
resource "azurerm_resource_group" "rg2" {
  name     = var.resource_group_2
  location = var.rg2_location
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
###Vnet2 peering
resource "azurerm_virtual_network_peering" "peering2" {
  name                      = "peer2to1"
  resource_group_name       = azurerm_resource_group.rg2.name
  virtual_network_name      = azurerm_virtual_network.vnet2.name
  remote_virtual_network_id = azurerm_virtual_network.vnet1.id
}
###RG2 SQL SERVER AND DATABASE
resource "azurerm_sql_server" "rg2sql1" {
  name                         = "rg2sql1"
  resource_group_name          = azurerm_resource_group.rg2.name
  location                     = azurerm_resource_group.rg2.location
  version                      = "12.0"
  administrator_login          = "azureuser"
  administrator_login_password = "Pa55w.rd"
}
resource "azurerm_sql_server" "rg2sql2" {
  name                         = "rg2sql2"
  resource_group_name          = azurerm_resource_group.rg2.name
  location                     = azurerm_resource_group.rg2.location
  version                      = "12.0"
  administrator_login          = "azureuser"
  administrator_login_password = "Pa55w.rd"
}
resource "azurerm_sql_database" "rg2db" {
  name                = "rg2db"
  resource_group_name = azurerm_resource_group.rg2.name
  location            = azurerm_resource_group.rg2.location
  server_name         = azurerm_sql_server.rg2sql1.name
}
##### rg2 SQL application gateway
resource "azurerm_application_gateway" "rg2sqlappgw" {
  name                = "rg2-sql-app-gw"
  resource_group_name = azurerm_resource_group.rg2.name
  location            = azurerm_resource_group.rg2.location

  sku {
    name     = "WAF_Medium"
    tier     = "WAF"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = azurerm_subnet.subnet8.id
  }


  frontend_port {
    name = "feport"
    port = 1433
  }

  frontend_ip_configuration {
    name      = "private-ip-configuration"
    subnet_id = azurerm_subnet.subnet8.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.1.8.100"
  }

  backend_address_pool {
    name = "sql-app-gw-pool"
    fqdns = ["rg2sql1.database.windows.net","rg2sql2.database.windows.net"]
    
  }
  
  probe {
    name                = "probe"
    protocol            = "http"
    path                = "/"
    host                = "rg2sql1.database.windows.net"
    interval            = "30"
    timeout             = "30"
    unhealthy_threshold = "3"
  }

  backend_http_settings {
    name                  = "http_setting"
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 1433
    protocol              = "Http"
    probe_name            = "probe"
    request_timeout       = 60
  }

  http_listener {
    name                           = "listener"
    frontend_ip_configuration_name = "private-ip-configuration"
    frontend_port_name             = "feport"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routing_rule"
    rule_type                  = "Basic"
    http_listener_name         = "listener"
    backend_address_pool_name  = "sql-app-gw-pool"
    backend_http_settings_name = "http_setting"
  }
}
# # Create the web app, pass in the App Service Plan ID, and deploy code from a public GitHub repo
resource "azurerm_app_service" "app-service-westus" {
  name                = "as-westus"
  location            = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name
  app_service_plan_id = azurerm_app_service_plan.app-service-plan-westus.id
  source_control {
    repo_url           = "https://github.com/DerekYZ/html-docs-hello-world"
    branch             = "master"
    manual_integration = true
    use_mercurial      = false
  }
}
# Create Application gateway Dynamic Public IP Addresses
resource "azurerm_public_ip" "pip_west" {
  name                = "pip-westus"
  location            = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name
  allocation_method   = "Dynamic"
}
# Create Application Gateways
resource "azurerm_application_gateway" "application-gateway-west" {
  name                = "agw-west"
  resource_group_name = azurerm_resource_group.rg2.name
  location            = azurerm_resource_group.rg2.location

  sku {
    name     = "Standard_Medium"
    tier     = "Standard"
    capacity = 4
  }

  gateway_ip_configuration {
    name      = "west-gw-ipconfig"
    subnet_id = "${azurerm_virtual_network.vnet2.id}/subnets/${azurerm_subnet.subnet6.name}"
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend"
    public_ip_address_id = azurerm_public_ip.pip_west.id
  }

  backend_address_pool {
    name  = "AppService"
    fqdns = ["${azurerm_app_service.app-service-westus.name}.azurewebsites.net"]
  }

  http_listener {
    name                           = "http"
    frontend_ip_configuration_name = "frontend"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  probe {
    name                = "probe"
    protocol            = "http"
    path                = "/"
    host                = "${azurerm_app_service.app-service-westus.name}.azurewebsites.net"
    interval            = "30"
    timeout             = "30"
    unhealthy_threshold = "3"
  }

  backend_http_settings {
    name                                = "http"
    cookie_based_affinity               = "Disabled"
    port                                = 80
    protocol                            = "Http"
    request_timeout                     = 1
    probe_name                          = "probe"
    pick_host_name_from_backend_address = true
  }

  request_routing_rule {
    name                       = "http"
    rule_type                  = "Basic"
    http_listener_name         = "http"
    backend_address_pool_name  = "AppService"
    backend_http_settings_name = "http"
  }
}
# Create Traffic Manager - West End Point
resource "azurerm_traffic_manager_endpoint" "tm-endpoint-west" {
  name                = "ep-Gateway-West"
  resource_group_name = azurerm_resource_group.rgtm.name
  profile_name        = azurerm_traffic_manager_profile.traffic-manager.name
  type                = "externalEndpoints"
  target              = azurerm_public_ip.pip_west.fqdn
  endpoint_location   = azurerm_public_ip.pip_west.location
}
#################### Route Table vnet2
resource "azurerm_route_table" "rg2rtb" {
  name                          = "rg2_route_table"
  location                      = azurerm_resource_group.rg2.location
  resource_group_name           = azurerm_resource_group.rg2.name
  disable_bgp_route_propagation = false

    route {
    name                   = "web-to-SQL"
    address_prefix         = "10.2.6.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.2.8.100"
  }
    route {
    name                   = "bussiniess-to-SQL"
    address_prefix         = "10.2.7.0/24"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.2.8.100"
  }
}

resource "azurerm_subnet_route_table_association" "rg2rtassociate1" {
  subnet_id      = azurerm_subnet.subnet6.id
  route_table_id = azurerm_route_table.rg2rtb.id
}
resource "azurerm_subnet_route_table_association" "rg2rtassociate2" {
  subnet_id      = azurerm_subnet.subnet7.id
  route_table_id = azurerm_route_table.rg2rtb.id
}
resource "azurerm_subnet_route_table_association" "rg2rtassociate3" {
  subnet_id      = azurerm_subnet.subnet8.id
  route_table_id = azurerm_route_table.rg2rtb.id
}