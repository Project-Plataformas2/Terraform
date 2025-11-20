# En GKE, la configuración es dinámica y se obtiene con gcloud. 
# En su lugar, se proporcionan los datos de conexión:
output "gke_cluster_name" {
  description = "El nombre del Clúster de GKE."
  value       = google_container_cluster.gke_cluster.name
}

output "gke_cluster_location" {
  description = "La ubicación (región/zona) del Clúster de GKE."
  value       = google_container_cluster.gke_cluster.location
}

output "gke_master_endpoint" {
  description = "El endpoint del plano de control del clúster de GKE."
  value       = google_container_cluster.gke_cluster.endpoint
}

# --- OUTPUT PARA LA IP ESTÁTICA PÚBLICA ---

output "ingress_static_ip_address" {
  description = "IP pública estática reservada para el GKE Ingress."
  # Esta IP se referencia del recurso 'google_compute_global_address.ingress_static_ip'
  value       = google_compute_global_address.ingress_static_ip.address
}

# Para conectarte al clúster, utiliza:
# gcloud container clusters get-credentials ${gke_cluster_name} --region ${gke_cluster_location} --project ${gcp_project_id}
