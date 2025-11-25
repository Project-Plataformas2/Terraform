terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
   backend "gcs" {
    bucket  = "plataformas2-terraform-state"   # tu bucket de Terraform
    prefix  = "ecommerce-deploy/state"      # carpeta dentro del bucket
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}
