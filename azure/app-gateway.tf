# Bloque de variables locales para nombrar componentes internos de App Gateway
locals {
    backend_address_pool_name      = "backend_address_pool"
    frontend_port_name             = "frontend_port_http"
    frontend_ip_configuration_name = "frontend_ip_configuration"
    http_setting_name              = "http_setting"
    listener_name                  = "listener_http"
    request_routing_rule_name      = "request_routing_rule"
    redirect_configuration_name    = "redirect_configuration"
}


# 4. Dirección IP Pública para la Application Gateway
resource "azurerm_public_ip" "pip_appgateway" {
    name                = "pip-appgateway"
    resource_group_name = azurerm_resource_group.example.name
    location            = azurerm_resource_group.example.location
    allocation_method   = "Static"
    sku                 = "Standard"
}

# 5. Application Gateway
resource "azurerm_application_gateway" "appgateway" {
  name                = "appgateway-aks"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }
  
  # --- CORRECCIÓN AÑADIDA: Bloque SSL Policy para resolver el error TLS obsoleto ---
  ssl_policy {
    # Usamos una política predefinida moderna
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101" 
  }
  # ---------------------------------------------------------------------------------

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip_appgateway.id
  }

  # Puerto 80 para la escucha inicial (AGIC gestionará el 443)
  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  # IMPORTANTE: El backend pool inicialmente no tiene IPs, ya que AGIC lo llenará con las IPs de los pods de AKS
  backend_address_pool {
    name = local.backend_address_pool_name
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    # Referencia a la subred creada arriba
    subnet_id = azurerm_subnet.snet-appgateway.id
  }

  # Configuraciones HTTP (la comunicación interna con AKS)
  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 8080 
    protocol              = "Http"
    request_timeout       = 60
  }

  # Listener inicial en el puerto 80 (AGIC creará el Listener 443 cuando vea un Ingress TLS)
  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }
  

  # Regla de enrutamiento básica
  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 9 # Prioridad requerida (ya presente en tu ejemplo)
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}