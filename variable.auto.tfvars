#cred
subscription_id = "f6a7723b-56ed-4572-a4b2-0f147ad4fd1b"
client_id       = "6aa952af-b787-4036-bee1-59c59c33a631"
client_secret   = "ZwP7Q~v6WmpgxiNNuiodP0l04WrS9FYjI-9Zd"
tenant_id       = "33da9f3f-4c1a-4640-8ce1-3f63024aea1d"

#resource group
resource_group_1 = "Team-1_Project-2_Primary-RG"
rg1_location     = "eastus"
resource_group_2 = "Team-1_Project-2_Secondary-RG"
rg2_location     = "westus"
resource_group_traffic-manager = "Team-1_Project-2_TM-RG"
rgtm_location                  = "eastus"

#vnet/ subnet varaiables
region_01_virtual_network = "vnet1"
region_02_virtual_network = "vnet2"
vnet1_address_space       = ["10.1.0.0/16"]
vnet2_address_space       = ["10.2.0.0/16"]
vnet1_NSG_name            = "vnet1_NSG"
vnet2_NSG_name            = "vnet2_NSG"
subnet1                   = "WebServers_Subnet1"
subnet1_address           = "10.1.1.0/24"
subnet2                   = "BusinessServers_Subnet2"
subnet2_address           = "10.1.2.0/24"
subnet3                   = "DataBases_Sbunet3"
subnet3_address           = "10.1.3.0/24"
subnet4                   = "Bastion_Subnet4"
subnet4_address           = "10.1.4.0/24"
subnet5                   = "Application_Gateway_Subnet5"
subnet5_address           = "10.1.5.0/24"
subnet6                   = "WebServers_Subnet6"
subnet6_address           = "10.2.6.0/24"
subnet7                   = "BusinessServers_Subnet7"
subnet7_address           = "10.2.7.0/24"
subnet8                   = "DataBases_Sbunet8"
subnet8_address           = "10.2.8.0/24"
subnet9                   = "Bastion_Subnet9"
subnet9_address           = "10.2.9.0/24"
subnet10                  = "Application_Gateway_Subnet10"
subnet10_address          = "10.2.10.0/24"


region_01_nic = "Region_01_nic"
#PiP
region_01_PIP = "region_01_PIP"

#LB
private_balancer_apps_name     = "Priavate-Balancer-apps"
frontend_ip_configuration_name = "private-lb-fip-Internal"
fip_private_ip_address         = "10.1.1.100"
#app service plan, and sql server database
app_plan                = "app_service_plan_name"
webapp                  = "app_service_name"
region1sql           = "sqlserver-region1"
sql_database_name1         = "sql_database_name1"
sql_database_name2        = "sql_database_name2"
sql_admin_login         = "azureuser"
sql_admin_password      = "Pa55w0rd"
