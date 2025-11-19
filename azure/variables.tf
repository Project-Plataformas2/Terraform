
variable "resource_group_location" {
  description = "La región de Azure donde se desplegarán los recursos."
  type        = string
  default     = "westus3" 
}


variable "resource_group_name" {
  description = "El nombre del Grupo de Recursos de Azure."
  type        = string
  default     = "myAKSGroup"
}

variable "aks_cluster_name" {
  description = "El nombre deseado para el clúster de AKS."
  type        = string
  default     = "myAKSCluster"
}

variable "aks_dns_prefix" {
  description = "El prefijo DNS para el clúster de AKS."
  type        = string
  default     = "myaks"
}


variable "aks_node_vm_size" {
    description = "El tamaño de la VM para los nodos de AKS."
    type        = string
#default     = "Standard_D4s_v3" # 4 vCPU, 16 GB RAM
   # default     = "Standard_D2s_v3" # 2 vCPU, 8 GB RAM
   default = "Standard_B2ms" # 2 vCPU, 8 GB RAM
}

variable "prefix" {
  type    = string
  default = "225"
}