#cred
subscription_id = "3ee423de-a014-4976-893e-939f7a0664fe"
client_id       = "7636e8d6-1182-40ef-a64c-da5f105f304d"
client_secret   = ""
tenant_id       = "5b6905f6-8a74-40fb-ace9-b77f197e5113"

#resource group
resource_group_1               = "Team-1_Project-2_Primary-RG-final2"
rg1_location                   = "eastus"
resource_group_2               = "Team-1_Project-2_Secondary-RG-final2"
rg2_location                   = "westus"
resource_group_traffic-manager = "Team-1_Project-2_TM-RG-final2"
rgtm_location                  = "eastus"

#vnet/ subnet varaiables
region_01_virtual_network = "vnet1"
region_02_virtual_network = "vnet2"
vnet1_address_space       = ["10.1.0.0/16"]
vnet2_address_space       = ["10.2.0.0/16"]
vnet1_NSG_name            = "vnet1_NSG"
vnet2_NSG_name            = "vnet2_NSG"
subnet1                   = "Web_Subnet1"
subnet1_address           = "10.1.1.0/24"
subnet2                   = "Business_Subnet2"
subnet2_address           = "10.1.2.0/24"
subnet3                   = "SQL_Sbunet3"
subnet3_address           = "10.1.3.0/24"
subnet4                   = "AzureBastionSubnet"
subnet4_address           = "10.1.4.0/24"
subnet6                   = "Web_Subnet6"
subnet6_address           = "10.2.6.0/24"
subnet7                   = "Business_Subnet7"
subnet7_address           = "10.2.7.0/24"
subnet8                   = "SQL_Sbunet8"
subnet8_address           = "10.2.8.0/24"
subnet9                   = "AzureBastionSubnet"
subnet9_address           = "10.2.9.0/24"

#LB
rg1_private_balancer_name     = "rg1_Bussiness_LB"
blb_frontend_ip_configuration_name = "bussiness_private-lb-fip-Internal"
fip_private_ip_address         = "10.1.2.100"
#app service plan, and sql server database
app_plan           = "app_service_plan_name"
webapp             = "app_service_name"
region1sql         = "sqlserver-region1"
sql_database_name1 = "sql_database_name1"
sql_database_name2 = "sql_database_name2"
sql_admin_login    = "azureuser"
sql_admin_password = "Pa55w0rd"
