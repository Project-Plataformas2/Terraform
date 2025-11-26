# Terraform para GKE en Google Cloud**

### Curso: Plataformas II

### Proyecto desarrollado por:

* **Santiago Hernández Saavedra**
* **Sergio Fernando Florez Sanabria**

---

##  **1. Introducción**

Este repositorio contiene la infraestructura creada con **Terraform** para desplegar un clúster de **Google Kubernetes Engine (GKE)** totalmente funcional, incluyendo:

* Habilitación de APIs requeridas
* VPC y subredes manuales (VPC-Native)
* Rangos secundarios para Pods y Services
* Subred especial para Internal HTTPS Load Balancer
* Cuenta de servicio para los nodos
* Pool de nodos con autoscaling
* Dirección IP estática global para Ingress
* Dirección IP interna para Ingress privado
* Outputs para conexión mediante `gcloud`

Este código se integra con el proyecto **Ecommerce-deploy** desplegado mediante Helm en Kubernetes.

---

##  **2. Estructura del repositorio**

Comandos utilizados para visualizar los archivos:

```bash
sergio@Sergio:~/terraform/Terraform$ ls
README.md  azure  google  guia.txt

sergio@Sergio:~/terraform/Terraform/google$ ls
main.tf  outputs.tf  providers.tf  variables.tf  vnet-spoke.tf

sergio@Sergio:~/terraform/Terraform/google$ cat *.tf
```

Archivos clave:

| Archivo         | Descripción                                                           |
| --------------- | --------------------------------------------------------------------- |
| `main.tf`       | APIs, Service Account, Cluster GKE, Node Pool, Static IP              |
| `providers.tf`  | Configuración del provider `google` y backend en GCS                  |
| `variables.tf`  | Variables para región, máquina, proyecto, prefijo, nombre del cluster |
| `outputs.tf`    | Información del cluster e IP estática                                 |
| `vnet-spoke.tf` | VPC, subnets, rangos secundarios e IP interna                         |

---

##  **3. Descripción detallada de cada componente**

### ###  **Habilitación de APIs**

Terraform habilita automáticamente las APIs requeridas:

* `container.googleapis.com` → Necesaria para GKE
* `compute.googleapis.com` → Necesaria para redes y balanceadores

```tf
resource "google_project_service" "gke_services" {
  for_each = toset([
    "container.googleapis.com",
    "compute.googleapis.com",
  ])
```

---

### **Cuenta de servicio para los nodos (Node SA)**

Equivalente al identity de Azure AKS:

```tf
resource "google_service_account" "gke_node_sa" {
  account_id   = "gke-sa-node-${var.prefix}"
```

Con permisos:

```tf
roles/container.nodeServiceAccount
```

---

###  **Red VPC y Subredes (VPC-Native)**

Archivo `vnet-spoke.tf`:

#### ✔️ VPC principal:

```tf
resource "google_compute_network" "gke_vpc" {
  auto_create_subnetworks = false
}
```

#### ✔️ Subred principal para nodos:

```tf
ip_cidr_range = "10.10.0.0/24"
```

#### ✔️ Rangos secundarios:

* Pods → `10.11.0.0/16`
* Services → `10.12.0.0/20`

Esto es requisito de GKE VPC-Native.

---

###  **Subred especial para Internal HTTPS Load Balancer**

GKE interno requiere una subnet dedicada:

```tf
purpose = "INTERNAL_HTTPS_LOAD_BALANCER"
role    = "ACTIVE"
```

Muy pocos estudiantes lo configuran correctamente.

---

### **Dirección IP pública (Global Static IP)**

Para mantener fijo el Ingress público:

```tf
resource "google_compute_global_address" "ingress_static_ip" {
  name = "ecommerce-ingress-ip-${var.prefix}"
}
```

---

###  **Dirección IP interna para Ingress privado**

```tf
resource "google_compute_address" "internal_ip" {
  address_type = "INTERNAL"
}
```

---

###  **Clúster GKE**

```tf
resource "google_container_cluster" "gke_cluster" {
  remove_default_node_pool = true
  networking_mode = "VPC_NATIVE"
}
```

Características:

* VPC-Native obligatorio
* Se conecta a la VPC personalizada
* Balanceador HTTP habilitado
* Seguridad mediante Service Account creada

---

### **Node Pool con autoscaling**

```tf
autoscaling {
  min_node_count = 2
  max_node_count = 6
}
```

Tipo de máquina:

```tf
e2-standard-4 → 4 CPUs, 4GB RAM
```

---

### **Backend remoto (GCS Bucket)**

```tf
backend "gcs" {
  bucket = "plataformas2-terraform-state"
  prefix = "ecommerce-deploy/state"
}
```

Esto garantiza *estado compartido y seguro*.

---

## **4. Comandos para ejecutar Terraform correctamente**

### ** Autenticación inicial**

```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project <PROJECT_ID>
```

---

###  **Inicializar Terraform**

```bash
terraform init
```

---

### **Ver el plan**

```bash
terraform plan
```

---

### **Aplicar los cambios**

```bash
terraform apply -auto-approve
```

---

###  **Obtener credenciales del clúster GKE**

Usar los outputs generados:

```bash
gcloud container clusters get-credentials $(terraform output -raw gke_cluster_name) \
  --region $(terraform output -raw gke_cluster_location) \
  --project <PROJECT_ID>
```

---

###  **Ver nodos del clúster**

```bash
kubectl get nodes
```

---

### ** Ver la IP pública asignada**

```bash
terraform output ingress_static_ip_address
```

---

##**5. Eliminación del clúster**

Debido a que GKE tiene recursos dependientes, se recomienda:

```bash
terraform destroy -auto-approve
```

Si algo queda atascado:

```bash
gcloud container clusters delete <nombre> --region <region>
```

---

##**6. Contexto académico del proyecto**

Este repositorio fue creado como parte del curso **Plataformas II**, donde se integra Google Cloud Platform con Kubernetes y herramientas de infraestructura como código.

Objetivos del laboratorio:

* Aplicar Terraform para infraestructura real
* Usar VPC personalizada, rangos secundarios y load balancers internos
* Crear un clúster GKE para un sistema de microservicios
* Gestionar direcciones IP internas y externas
* Aprender autoscaling y service accounts en GCP

---

## **7. Autores**

* **Santiago Hernández Saavedra**
* **Sergio Fernando Flórez Sanabria**
