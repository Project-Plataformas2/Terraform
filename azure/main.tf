# 1. Grupo de Recursos de Azure
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

# 2. Clúster de Kubernetes (AKS)
resource "azurerm_kubernetes_cluster" "example" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = var.aks_dns_prefix
  private_cluster_enabled = false

  default_node_pool {
    name       = "default"
    vm_size    = var.aks_node_vm_size
    vnet_subnet_id  = azurerm_subnet.snet-aks.id
    min_count            = 2
    max_count            = 5
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_plugin_mode = "overlay"
    network_policy = "cilium"
    network_data_plane  = "cilium"
    outbound_type       = "loadBalancer"
    load_balancer_sku   = "standard"
  }

  web_app_routing {
    dns_zone_ids = [  ]
  }
  lifecycle {
    ignore_changes = [
      default_node_pool.0.upgrade_settings
    ]
  }
}

# Required to create internal Load Balancer for Nginx Ingress Controller
resource "azurerm_role_assignment" "network-contributor" {
  scope                = azurerm_subnet.snet-aks-lb.id # azurerm_virtual_network.vnet-spoke.id # 
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.example.identity.0.principal_id
}

resource "terraform_data" "aks-get-credentials" {
  triggers_replace = [
    azurerm_kubernetes_cluster.example.id
  ]

  provisioner "local-exec" {
    command = "az aks get-credentials -n ${azurerm_kubernetes_cluster.example.name} -g ${azurerm_kubernetes_cluster.example.resource_group_name} --overwrite-existing"
  }
}