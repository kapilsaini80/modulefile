module "resource_group" {
  source                  = "../Child_Module/azurerm_resource_group"
  resource_group_name     = "TodoAppRG051"
  resource_group_location = "West Europe"

}

module "virtual_network" {
  source                        = "../Child_Module/azurerm_virtual_network"
  resource_group_name           = "TodoAppRG051"
  resource_group_location       = "West Europe"
  virtual_network_name          = "TodoAppVNet"
  virtual_network_address_space = ["10.0.0.0/24"]
  depends_on                    = [module.resource_group]
}
module "Backend_subnet" {
  source                  = "../Child_Module/azurerm_subnet"
  resource_group_name     = "TodoAppRG051"
  resource_group_location = "West Europe"
  virtual_network_name    = "TodoAppVNet"
  subnet_name             = "TodoAppSubnet_Backend"
  subnet_address_prefix   = ["10.0.0.0/25"]
  depends_on              = [module.virtual_network]
}
module "Frontend_subnet" {
  source                  = "../Child_Module/azurerm_subnet"
  resource_group_name     = "TodoAppRG051"
  resource_group_location = "West Europe"
  virtual_network_name    = "TodoAppVNet"
  subnet_name             = "TodoAppSubnet_frontend"
  subnet_address_prefix   = ["10.0.0.128/25"]
  depends_on              = [module.virtual_network]
}
module "Fpublic_ip" {
  source                  = "../Child_Module/azuerm_public_ip"
  resource_group_name     = "TodoAppRG051"
  location                = "West Europe"
  public_ip_name          = "FTodoAppPublicIP"
  allocation_method       = "Static"
  depends_on              = [module.resource_group]
}
module "Bpublic_ip" {
  source                  = "../Child_Module/azuerm_public_ip"
  resource_group_name     = "TodoAppRG051"
  location                = "West Europe"
  public_ip_name          = "BTodoAppPublicIP"
  allocation_method       = "Static"
  depends_on              = [module.resource_group]
}

module "Bnetwork_interface" {
  source                  = "../Child_Module/azurerm_nic"
  nic_vnet_name           = "TodoAppVNet"
  nic_resource_group_name = "TodoAppRG051"
  nic_resource_location   = "West Europe"
  nic_name                = "BTodoAppNIC"
  nic_ip_config_name      = "BTodoAppNICConfig"
  nic_subnet_name         = "TodoAppSubnet_Backend"
  nic_public_Ip_name      = "BTodoAppPublicIP"
  depends_on              = [module.Backend_subnet, module.Bpublic_ip]
}
module "Fnetwork_interface" {
  source                  = "../Child_Module/azurerm_nic"
  nic_vnet_name           = "TodoAppVNet"
  nic_resource_group_name = "TodoAppRG051"
  nic_resource_location   = "West Europe"
  nic_name                = "FTodoAppNIC"
  nic_ip_config_name      = "FTodoAppNICConfig"
  nic_subnet_name         = "TodoAppSubnet_Frontend"
  nic_public_Ip_name      = "FTodoAppPublicIP"
  depends_on              = [module.Frontend_subnet, module.Fpublic_ip]
}
module "backend_virtual_machine" {
  source                   = "../Child_Module/azurerm_virtual_machine"
  resource_group_name      = "TodoAppRG051"
  resource_location        = "West Europe"
  virtual_machine_name     = "TodoAppBackendVM"
  virtual_machine_username = "azureuser"
  virtual_machine_password = "Devops@12345"
  nic_name                 = "BTodoAppNIC"
  depends_on               = [module.Backend_subnet, module.Bnetwork_interface, module.Bpublic_ip]
}
module "Frontend_virtual_machine" {
  source                   = "../Child_Module/azurerm_virtual_machine"
  resource_group_name      = "TodoAppRG051"
  resource_location        = "West Europe"
  virtual_machine_name     = "TodoAppFrontendVM"
  virtual_machine_username = "azureuser1"
  virtual_machine_password = "Devops@12345"
  nic_name                 = "FTodoAppNIC"
  depends_on               = [module.Frontend_subnet, module.Fnetwork_interface, module.Fpublic_ip]
}
module "mssql_server" {
  source                    = "../Child_Module/azuerm_mssql_server"
  mssql_resource_group_name = "TodoAppRG051"
  mssql_location            = "North Europe"
  mssql_server_name         = "todoappmssqlserver0011"
  mssql_username            = "sqladminuser"
  mssql_password            = "P@ssw0rdMSSQL123!"
  depends_on                = [module.resource_group]
}
module "mssql_database" {
  source                    = "../Child_Module/azurerm_mssql_database"
  mssql_server_name         = "todoappmssqlserver0011"
  mssql_resource_group_name = "TodoAppRG051"
  mssql_database_name       = "todoappaatabase01"
  depends_on                = [module.mssql_server]
}
module "Fazurerm_nsg" {
  source                  = "../Child_Module/azurerm_nsg"
  nsg_location            = "West Europe"
  nsg_resource_group_name = "TodoAppRG051"
  nsg_name                = "FTodoAppNSG"
  nic_name                = "FTodoAppNIC"
  nic_resource_group_name = "TodoAppRG051"
  depends_on              = [module.Fnetwork_interface]
}
module "Bazurerm_nsg" {
  source                  = "../Child_Module/azurerm_nsg"
  nsg_location            = "West Europe "
  nsg_resource_group_name = "TodoAppRG051"
  nsg_name                = "BTodoAppNSG"
  nic_name                = "BTodoAppNIC"
  nic_resource_group_name = "TodoAppRG051"
  depends_on              = [module.Bnetwork_interface]
}
