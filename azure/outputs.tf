# Muestra la configuración RAW de kube para conectarse al clúster
output "kube_config_raw" {
  description = "La configuración RAW de Kube para conectarse al clúster de AKS."
  value       = azurerm_kubernetes_cluster.example.kube_config_raw
  sensitive   = true # Marca el valor como sensible para que no se imprima fácilmente
}

# Muestra el nombre del Grupo de Recursos creado
output "resource_group_name" {
  description = "El nombre del Grupo de Recursos creado."
  value       = azurerm_resource_group.example.name
}

# Muestra el nombre del Clúster de AKS creado
output "aks_cluster_name" {
  description = "El nombre del Clúster de AKS creado."
  value       = azurerm_kubernetes_cluster.example.name
}

output "pip_app_gateway" {
  value = azurerm_public_ip.pip_appgateway.ip_address
}