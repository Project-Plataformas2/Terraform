resource "azurerm_resource_group" "rg" {
  name     = "rg-aks-ingress-appgateway-${var.prefix}"
  location = azurerm_resource_group.example.location
}