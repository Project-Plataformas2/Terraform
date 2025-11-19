# VNet Spoke donde se desplegara el cluster AKS y otros recursos
resource "azurerm_virtual_network" "vnet-spoke" {
  name                = "vnet-spoke"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.10.0.0/16"]
}
# Subnets dentro de la VNet Spoke que sera donde esta el cluster AKS
resource "azurerm_subnet" "snet-aks" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_virtual_network.vnet-spoke.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-spoke.name
  address_prefixes     = ["10.10.0.0/24"]
}
# Subnet para el Load Balancer del AKS
resource "azurerm_subnet" "snet-aks-lb" {
  name                 = "snet-aks-lb"
  resource_group_name  = azurerm_virtual_network.vnet-spoke.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-spoke.name
  address_prefixes     = ["10.10.1.0/24"]
}
# Subnet para el Application Gateway
resource "azurerm_subnet" "snet-appgateway" {
  name                 = "snet-appgateway"
  resource_group_name  = azurerm_virtual_network.vnet-spoke.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-spoke.name
  address_prefixes     = ["10.10.2.0/24"]
}
# Subnet para las VMs de prueba
resource "azurerm_subnet" "snet-vm" {
  name                 = "snet-vm"
  resource_group_name  = azurerm_virtual_network.vnet-spoke.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-spoke.name
  address_prefixes     = ["10.10.3.0/24"]
}