#cred
subcription_id = ""
client_id      = ""
client_secret  = ""
tenant_id      = ""

#resource group
team1rg1 = "Team-1_project-2_Test"
location = "eastus"

#Network varaiables
region_01_virtual_network = "vnet1"
address_space             = ["10.0.0.0/16"]
network1_NSG              = "network_security_group"
subnet1                   = "webservers"
subnet_address            = "10.0.1.0/24"
subnet2                   = "buisnessservers"
subnet2_address           = "10.0.2.0/24"
subnet3                   = "databases"
subnet3_address           = "10.0.3.0/24"
subnet4                   = "Bastion_Subnet"
subnet4_address_space     = ["192.168.1.224/24"]


#security variables
security_rule_name                       = "allow-ssh"
security_rule_priority                   = 100
security_rule_direction                  = "Inbound"
security_rule_access                     = "Allow"
security_rule_protocol                   = "Tcp"
security_rule_source_port_range          = "*"
security_rule_destination_port_range     = "*"
security_rule_source_address_prefix      = "*"
security_rule_destination_address_prefix = "*"
