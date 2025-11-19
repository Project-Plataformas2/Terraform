terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0" # Usa la versión 3.0 o superior
    }
  }
}

provider "azurerm" {
  features {} # Este bloque es necesario para habilitar todas las funcionalidades
}