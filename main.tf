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
resource "azurerm_subnet" "subnet5" {
  name                 = var.subnet5
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefix       = var.subnet5_address
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
# resource "azurerm_subnet_network_security_group_association" "associate_nsg_subnet4" {
#   subnet_id                 = azurerm_subnet.subnet4.id
#   network_security_group_id = azurerm_network_security_group.vnet1_Network_Security_Group.id
# }
resource "azurerm_subnet_network_security_group_association" "associate_nsg_subnet5" {
  subnet_id                 = azurerm_subnet.subnet5.id
  network_security_group_id = azurerm_network_security_group.vnet1_Network_Security_Group.id
}

#********************************************************FIRST INTERNAL LOAD BALANCER************************************************************
# #Private Load Balancer. (this is the deployment of load balancer )
# resource "azurerm_lb" "Private_Balancer_apps" {
#   name                = var.private_balancer_apps_name
#   resource_group_name = azurerm_resource_group.rg1.name
#   location            = azurerm_resource_group.rg1.location

#   frontend_ip_configuration {
#     name                          = var.frontend_ip_configuration_name
#     subnet_id                     = azurerm_subnet.subnet1.id
#     private_ip_address_allocation = "Static"
#     private_ip_address            = var.fip_private_ip_address
#   }

# }

# #deployment of backend address pool
# resource "azurerm_lb_backend_address_pool" "PLB_Backend1" {
#   loadbalancer_id = azurerm_lb.Private_Balancer_apps.id
#   name            = "PLB_BE1"
# }

# #deployment of LoadBalancer Health Probe.
# resource "azurerm_lb_probe" "PrivateLB_Probe1" {
#   resource_group_name = azurerm_resource_group.rg1.name
#   loadbalancer_id     = azurerm_lb.Private_Balancer_apps.id
#   name                = "ssh-running-probe"
#   port                = 22
# }
# #depoloyment of Load Balancer Rule.
# resource "azurerm_lb_rule" "lb-rule" {
#   resource_group_name            = azurerm_resource_group.rg1.name
#   loadbalancer_id                = azurerm_lb.Private_Balancer_apps.id
#   name                           = "LBRule"
#   protocol                       = "Tcp"
#   frontend_port                  = 22
#   backend_port                   = 22
#   frontend_ip_configuration_name = var.frontend_ip_configuration_name
#   backend_address_pool_id        = azurerm_lb_backend_address_pool.PLB_Backend1.id
#   probe_id                       = azurerm_lb_probe.PrivateLB_Probe1.id
# }

#bastion host
resource "azurerm_public_ip" "bastionpip" {
  name                = "eastpip"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  allocation_method   = "Static"
  sku = "Standard"
}

resource "azurerm_bastion_host" "eastbastion" {
  name                = "esastbastionhost"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.subnet4.id
    public_ip_address_id = azurerm_public_ip.bastionpip.id
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

######################################## SQL Server and Database  #####################
resource "azurerm_sql_server" "sqls1" {
  name                         = var.region1sql
  resource_group_name          = azurerm_resource_group.rg1.name
  location                     = azurerm_resource_group.rg1.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
}
resource "azurerm_sql_server" "sqls2" {
  name                         = var.region2sql
  resource_group_name          = azurerm_resource_group.rg2.name
  location                     = azurerm_resource_group.rg2.location
  version                      = "12.0"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
}

resource "azurerm_sql_database" "r1db1" {
  name                = var.sql_database_name1
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  server_name         = azurerm_sql_server.sqls1.name
}
resource "azurerm_sql_database" "r1db2" {
  name                = var.sql_database_name2
  resource_group_name = azurerm_resource_group.rg2.name
  location            = azurerm_resource_group.rg2.location
  server_name         = azurerm_sql_server.sqls2.name
}

resource "azurerm_sql_failover_group" "sql-failover-group" {
  name                = "sql-failover-group"
  resource_group_name = azurerm_sql_server.sqls1.resource_group_name
  server_name         = azurerm_sql_server.sqls1.name
  databases           = [azurerm_sql_database.r1db1.id]
  partner_servers {
    id = azurerm_sql_server.sqls2.id
  }

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 60
  }
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
resource "azurerm_subnet" "subnet10" {
  name                 = var.subnet10
  resource_group_name  = azurerm_resource_group.rg2.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefix       = var.subnet10_address
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
# resource "azurerm_subnet_network_security_group_association" "associate_nsg_subnet9" {
#   subnet_id                 = azurerm_subnet.subnet9.id
#   network_security_group_id = azurerm_network_security_group.vnet2_Network_Security_Group.id
# }
resource "azurerm_subnet_network_security_group_association" "associate_nsg_subnet10" {
  subnet_id                 = azurerm_subnet.subnet10.id
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

#traffic manager resource group
resource "azurerm_resource_group" "rgtm" {
  name     = var.resource_group_traffic-manager
  location = var.rgtm_location
}

# Create App Service Plans
resource "azurerm_app_service_plan" "app-service-plan-eastus" {
  name                = "asp-eastus"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}
resource "azurerm_app_service_plan" "app-service-plan-westus" {
  name                = "asp-westus"
  location            = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

# Create the web app, pass in the App Service Plan ID, and deploy code from a public GitHub repo
resource "azurerm_app_service" "app-service-eastus" {
  name                = "as-eastus"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  app_service_plan_id = azurerm_app_service_plan.app-service-plan-eastus.id
  source_control {
    repo_url           = "https://github.com/DerekYZ/html-docs-hello-world"
    branch             = "master"
    manual_integration = true
    use_mercurial      = false
  }
}

resource "azurerm_app_service" "app-service-westus" {
  name                = "as-westus"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  app_service_plan_id = azurerm_app_service_plan.app-service-plan-westus.id
  source_control {
    repo_url           = "https://github.com/DerekYZ/html-docs-hello-world"
    branch             = "master"
    manual_integration = true
    use_mercurial      = false
  }
}

# Create Application gateway Dynamic Public IP Addresses
resource "azurerm_public_ip" "pip_east" {
  name                = "pip-eastus"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  allocation_method   = "Dynamic"
}
resource "azurerm_public_ip" "pip_west" {
  name                = "pip-westus"
  location            = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name
  allocation_method   = "Dynamic"
}

# Create Application Gateways
resource "azurerm_application_gateway" "application-gateway-east" {
  name                = "agw-east"
  resource_group_name = "${azurerm_resource_group.rg1.name}"
  location            = "${azurerm_resource_group.rg1.location}"

  sku {
    name     = "Standard_Medium"
    tier     = "Standard"
    capacity = 4
  }

  gateway_ip_configuration {
    name      = "east-gw-ipconfig"
    subnet_id = "${azurerm_virtual_network.vnet1.id}/subnets/${azurerm_subnet.subnet5.name}"
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend"
    public_ip_address_id = "${azurerm_public_ip.pip_east.id}"
  }

  backend_address_pool {
    name        = "AppService"
    fqdns = ["${azurerm_app_service.app-service-eastus.name}.azurewebsites.net"]
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
    host                = "${azurerm_app_service.app-service-eastus.name}.azurewebsites.net"
    interval            = "30"
    timeout             = "30"
    unhealthy_threshold = "3"
  }

  backend_http_settings {
    name                  = "http"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
    probe_name            = "probe"
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
resource "azurerm_application_gateway" "application-gateway-west" {
  name                = "agw-west"
  resource_group_name = "${azurerm_resource_group.rg2.name}"
  location            = "${azurerm_resource_group.rg2.location}"

  sku {
    name     = "Standard_Medium"
    tier     = "Standard"
    capacity = 4
  }

  gateway_ip_configuration {
    name      = "west-gw-ipconfig"
    subnet_id = "${azurerm_virtual_network.vnet2.id}/subnets/${azurerm_subnet.subnet10.name}"
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend"
    public_ip_address_id = "${azurerm_public_ip.pip_west.id}"
  }

  backend_address_pool {
    name        = "AppService"
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
    name                  = "http"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
    probe_name            = "probe"
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

# Create Traffic Manager API Profile
resource "azurerm_traffic_manager_profile" "traffic-manager" {
  name                   = "Team1-p2-Traffic-Manager"
  resource_group_name    = "${azurerm_resource_group.rgtm.name}"
  traffic_routing_method = "Performance"

  dns_config {
    relative_name = "team1project2"
    ttl           = 300
  }

  monitor_config {
    protocol = "http"
    port     = 80
    path     = "/"
  }
}

# Create Traffic Manager - East End Point
resource "azurerm_traffic_manager_endpoint" "tm-endpoint-east" {
  name                = "ep-Gateway-East"
  resource_group_name = "${azurerm_resource_group.rgtm.name}"
  profile_name        = "${azurerm_traffic_manager_profile.traffic-manager.name}"
  type                = "externalEndpoints"
  target              = "${azurerm_public_ip.pip_east.fqdn}"
  endpoint_location   = "${azurerm_public_ip.pip_east.location}"
}

# Create Traffic Manager - West End Point
resource "azurerm_traffic_manager_endpoint" "tm-endpoint-west" {
  name                = "ep-Gateway-West"
  resource_group_name = "${azurerm_resource_group.rgtm.name}"
  profile_name        = "${azurerm_traffic_manager_profile.traffic-manager.name}"
  type                = "externalEndpoints"
  target              = "${azurerm_public_ip.pip_west.fqdn}"
  endpoint_location   = "${azurerm_public_ip.pip_west.location}"
}
#################### Route Table
# resource "azurerm_route_table" "rtb1" {
#   name                          = "route_table_1"
#   location                      = azurerm_resource_group.rg1.location
#   resource_group_name           = azurerm_resource_group.rg1.name
#   disable_bgp_route_propagation = false

#     route {
#     name                   = "example"
#     address_prefix         = "10.100.0.0/14"
#     next_hop_type          = "VirtualAppliance"
#     next_hop_in_ip_address = "10.10.1.1"
#   }
# }

# resource "azurerm_subnet_route_table_association" "example" {
#   subnet_id      = azurerm_subnet.example.id
#   route_table_id = azurerm_route_table.example.id
# }